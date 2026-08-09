local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"
local environment = require "test_environment"

local function filesystem()
  return {
    lstat = vim.uv.fs_lstat,
    mkdir = function(path) return vim.uv.fs_mkdir(path, 448) end,
    rmdir = vim.uv.fs_rmdir,
    unlink = vim.uv.fs_unlink,
    scandir = function(path)
      local scanner, error_message = vim.uv.fs_scandir(path)
      if not scanner then return nil, error_message end
      local entries = {}
      while true do
        local name = vim.uv.fs_scandir_next(scanner)
        if not name then break end
        table.insert(entries, name)
      end
      return entries
    end,
    now = vim.uv.hrtime,
    wait = vim.wait,
  }
end

local function fail_if_exists(path)
  if vim.uv.fs_lstat(path) then error("Refusing to reuse lifecycle path: " .. path, 0) end
end

local function mkdir(path)
  local entry = vim.uv.fs_lstat(path)
  if entry then
    if entry.type ~= "directory" then error("Expected directory: " .. path, 0) end
    return
  end
  assert(vim.uv.fs_mkdir(path, 448))
end

local function command(arguments)
  local result = vim.system(arguments, { text = true }):wait()
  if result.code ~= 0 then error(("Command failed: %s\n%s"):format(table.concat(arguments, " "), result.stderr), 0) end
  return result
end

local function write_json(path, value)
  local temporary = path .. ".tmp." .. tostring(vim.uv.hrtime())
  fail_if_exists(temporary)
  assert(vim.fn.writefile({ vim.json.encode(value) }, temporary) == 0)
  if not vim.uv.fs_rename(temporary, path) then
    vim.uv.fs_unlink(temporary)
    error("Cannot atomically publish " .. path, 0)
  end
end

local function clone(dependency, root)
  local destination = root .. "/" .. dependency.path
  mkdir(vim.fs.dirname(destination))
  command { "git", "clone", "--depth=1", "--single-branch", "--branch=" .. dependency.ref, dependency.url, destination }
  local result = command { "git", "-C", destination, "rev-parse", "HEAD" }
  return vim.trim(result.stdout)
end

local function copy_tree(source, destination, inventory, relative)
  local scanner = assert(vim.uv.fs_scandir(source))
  assert(vim.uv.fs_mkdir(destination, 448))
  while true do
    local name = vim.uv.fs_scandir_next(scanner)
    if not name then break end
    local source_path, destination_path = source .. "/" .. name, destination .. "/" .. name
    local entry = vim.uv.fs_lstat(source_path)
    if not entry or entry.type == "link" then
      error("Refusing to copy missing or symbolic-link source: " .. source_path, 0)
    end
    local child_relative = relative .. "/" .. name
    if entry.type == "directory" then
      copy_tree(source_path, destination_path, inventory, child_relative)
    elseif entry.type == "file" then
      assert(vim.uv.fs_copyfile(source_path, destination_path))
      local file = assert(io.open(destination_path, "rb"))
      table.insert(inventory, { path = child_relative, sha256 = vim.fn.sha256(file:read "*a") })
      file:close()
    else
      error("Refusing to copy unsupported source: " .. source_path, 0)
    end
  end
end

local function cleanup_staging()
  local entry = vim.uv.fs_lstat(config.staging_root)
  if not entry then return end
  if
    entry.type ~= "directory" or environment.find_symlink_component(config.root, config.staging_root, vim.uv.fs_lstat)
  then
    error("Unsafe bootstrap staging directory. Run `make test-clear` after resolving: " .. config.staging_root, 0)
  end
  local removed, remove_error = environment.remove_tree(filesystem(), config.staging_root)
  if not removed then error("Cannot clean bootstrap staging: " .. tostring(remove_error), 0) end
end

environment.with_lifecycle_lock(filesystem(), config.prepare_lock, function()
  local state = environment.classify(config, vim.uv.fs_lstat)
  if state == "marked" then
    config.assert_ready_environment()
    return
  end
  if state == "unmarked" then error("Unmarked or partial .tests environment. Run `make test-clear` then retry.", 0) end
  cleanup_staging()
  local staging = environment.paths_for_test_root(config.staging_root)
  local ok, failure = xpcall(function()
    mkdir(staging.test_root)
    mkdir(staging.test_root .. "/data")
    mkdir(staging.shared_data_dir)
    mkdir(staging.plugin_root)
    mkdir(staging.state_dir)
    mkdir(staging.cache_dir)
    mkdir(staging.test_lua_dir)
    local dependencies, lock = {}, {}
    for _, descriptor in ipairs(config.dependencies) do
      local commit = clone(descriptor, staging.test_root)
      local dependency = vim.tbl_extend("force", {}, descriptor, { commit = commit })
      table.insert(dependencies, dependency)
      lock[descriptor.name] = { branch = descriptor.ref, commit = commit }
    end
    local manifest = {
      schema = environment.schema,
      fingerprint = config.fingerprint,
      lockfile = "lazy-lock.json",
      dependencies = dependencies,
      copied_libraries = {},
    }
    local staged_valid, staged_error = config.validate_staged_repositories(dependencies, lock, staging.test_root)
    if not staged_valid then error("Generated staged repositories are invalid: " .. staged_error, 0) end
    local copied_libraries = {}
    for _, source in ipairs {
      {
        name = "luassert",
        source = staging.plugin_root .. "/luassert/src",
        destination = staging.test_lua_dir .. "/luassert",
      },
      { name = "say", source = staging.plugin_root .. "/say/src/say", destination = staging.test_lua_dir .. "/say" },
    } do
      local files = {}
      copy_tree(source.source, source.destination, files, "lua/" .. source.name)
      table.sort(files, function(left, right) return left.path < right.path end)
      copied_libraries[source.name] = { directory = "lua/" .. source.name, files = files }
    end
    manifest.copied_libraries = copied_libraries
    write_json(staging.lockfile, lock)
    write_json(staging.manifest, manifest)
    local valid, validation_error = environment.validate_ready({
      schema = environment.schema,
      fingerprint = config.fingerprint,
      manifest = "manifest.json",
      lockfile = "lazy-lock.json",
    }, manifest, lock, config.fingerprint, staging.test_root, vim.uv.fs_lstat, config.validation_requirements)
    if not valid then error("Generated test environment is invalid: " .. validation_error, 0) end
    write_json(staging.ready, {
      schema = environment.schema,
      fingerprint = config.fingerprint,
      manifest = "manifest.json",
      lockfile = "lazy-lock.json",
    })
    if vim.uv.fs_lstat(config.test_root) then error("Test environment appeared during bootstrap", 0) end
    assert(vim.uv.fs_rename(staging.test_root, config.test_root))
  end, debug.traceback)
  if not ok then
    local cleanup_ok, cleanup_error = environment.remove_tree(filesystem(), config.staging_root)
    if not cleanup_ok then failure = failure .. "\nBootstrap cleanup failed: " .. tostring(cleanup_error) end
    error(failure, 0)
  end
end)
