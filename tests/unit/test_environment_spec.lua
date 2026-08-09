local MiniTest = require "mini.test"
local environment = require "test_environment"
local config = require "config"

local T = MiniTest.new_set()

T["AUI-HARNESS-01 fingerprint is deterministic and schema-3"] = function()
  assert.equals(3, environment.schema)
  assert.equals("3fcd1267c83de09245e888931cd6e5e08efcc6a4afbc3e14a07f0ecade57b38d", config.fingerprint)
  assert.equals(64, #config.fingerprint)
end

local function with_temporary_root(callback)
  local root = vim.fn.tempname()
  local ok, result = xpcall(function() return callback(root) end, debug.traceback)
  vim.fn.delete(root, "rf")
  if not ok then error(result, 0) end
  return result
end

T["AUI-HARNESS-02 validates copied checksums and rejects changed files"] = function()
  with_temporary_root(function(root)
    vim.fn.mkdir(root .. "/lua/luassert", "p")
    vim.fn.writefile({ "content" }, root .. "/lua/luassert/init.lua")
    local files = { { path = "lua/luassert/init.lua", sha256 = vim.fn.sha256 "content\n" } }
    local library = { directory = "lua/luassert", files = files }
    assert.is_true(
      environment.validate_ready(
        { schema = 3, fingerprint = "f", manifest = "manifest.json", lockfile = "lazy-lock.json" },
        {
          schema = 3,
          fingerprint = "f",
          lockfile = "lazy-lock.json",
          dependencies = {},
          copied_libraries = { luassert = library },
        },
        {},
        "f",
        root,
        vim.uv.fs_lstat
      )
    )
    local marker = { schema = 3, fingerprint = "f", manifest = "manifest.json", lockfile = "lazy-lock.json" }
    local manifest = {
      schema = 3,
      fingerprint = "f",
      lockfile = "lazy-lock.json",
      dependencies = {},
      copied_libraries = { luassert = library },
    }
    local requirements = { dependencies = {}, copied_libraries = { luassert = "lua/luassert" } }
    assert.is_true(environment.validate_ready(marker, manifest, {}, "f", root, vim.uv.fs_lstat, requirements))
    manifest.copied_libraries = { unexpected = library }
    assert.is_false(environment.validate_ready(marker, manifest, {}, "f", root, vim.uv.fs_lstat, requirements))
    vim.fn.writefile({ "extra" }, root .. "/lua/luassert/extra.lua")
    assert.is_false(
      environment.validate_ready(
        { schema = 3, fingerprint = "f", manifest = "manifest.json", lockfile = "lazy-lock.json" },
        {
          schema = 3,
          fingerprint = "f",
          lockfile = "lazy-lock.json",
          dependencies = {},
          copied_libraries = { luassert = library },
        },
        {},
        "f",
        root,
        vim.uv.fs_lstat
      )
    )
    vim.fn.delete(root .. "/lua/luassert/extra.lua")
    vim.fn.writefile({ "changed" }, root .. "/lua/luassert/init.lua")
    assert.is_false(
      environment.validate_ready(
        { schema = 3, fingerprint = "f", manifest = "manifest.json", lockfile = "lazy-lock.json" },
        {
          schema = 3,
          fingerprint = "f",
          lockfile = "lazy-lock.json",
          dependencies = {},
          copied_libraries = { luassert = library },
        },
        {},
        "f",
        root,
        vim.uv.fs_lstat
      )
    )
  end)
end

T["AUI-HARNESS-03 classifies missing, marked, unmarked, and symbolic-link environments"] = function()
  local paths = environment.paths "/repository"
  assert.equals("missing", environment.classify(paths, function() end))
  assert.equals(
    "marked",
    environment.classify(paths, function(path)
      if path == paths.test_root then return { type = "directory" } end
      if path == paths.ready then return { type = "file" } end
    end)
  )
  assert.equals(
    "unmarked",
    environment.classify(paths, function(path) return path == paths.test_root and { type = "directory" } or nil end)
  )
  assert.equals(
    "/repository/.tests/external",
    environment.find_symlink_component(
      "/repository",
      "/repository/.tests/external/file",
      function(path) return path == "/repository/.tests/external" and { type = "link" } or nil end
    )
  )
  local entries = { root = { "link" } }
  assert.equals(
    "/tree/link",
    environment.find_tree_symlink(
      "/tree",
      function(path) return path == "/tree" and { type = "directory" } or { type = "link" } end,
      function() return "root" end,
      function(scanner)
        local name = entries[scanner][1]
        table.remove(entries[scanner], 1)
        return name
      end
    )
  )
end

T["AUI-HARNESS-04 repository validation rejects unexpected origin, changes, and unsafe tags"] = function()
  local dependency = config.dependencies[1]
  local root = "/repository/.tests"
  local stat = function(path)
    if path == root .. "/" .. dependency.path then return { type = "directory" } end
    if path == root .. "/" .. dependency.path .. "/doc/tags" then return { type = "file" } end
  end
  local runner = function(arguments)
    local last = arguments[#arguments]
    if last == "remote.origin.url" then return { code = 0, stdout = dependency.url } end
    if last == "HEAD" then return { code = 0, stdout = "abcdef0" } end
    return { code = 0, stdout = "!! doc/tags\n" }
  end
  assert.is_true(config.validate_repository(dependency, "abcdef0", runner, stat, root, "/repository", function() end))
  local wrong_origin = function(arguments)
    local response = runner(arguments)
    if arguments[#arguments] == "remote.origin.url" then response.stdout = "https://example.com/unexpected.git" end
    return response
  end
  local origin_valid, origin_error = config.validate_repository(
    dependency,
    "abcdef0",
    wrong_origin,
    stat,
    root,
    "/repository",
    function() end
  )
  assert.is_false(origin_valid)
  assert.equals("unexpected dependency origin: " .. dependency.name, origin_error)
  local wrong_head = function(arguments)
    local response = runner(arguments)
    if arguments[#arguments] == "HEAD" then response.stdout = "1234567" end
    return response
  end
  local head_valid, head_error = config.validate_repository(
    dependency,
    "abcdef0",
    wrong_head,
    stat,
    root,
    "/repository",
    function() end
  )
  assert.is_false(head_valid)
  assert.equals("unexpected dependency HEAD: " .. dependency.name, head_error)
  local dirty = function(arguments)
    local response = runner(arguments)
    if arguments[#arguments] == "--untracked-files=all" then response.stdout = "?? unexpected\n" end
    return response
  end
  assert.is_false(config.validate_repository(dependency, "abcdef0", dirty, stat, root, "/repository", function() end))
  assert.is_false(
    config.validate_repository(
      dependency,
      "abcdef0",
      runner,
      stat,
      root,
      "/repository",
      function() return root .. "/link" end
    )
  )
end

T["AUI-HARNESS-05 validates staged descriptors, locks, and repository trees"] = function()
  local root, commit = "/repository/.tests.bootstrap", string.rep("a", 40)
  local dependencies, lock, by_path = {}, {}, {}
  for _, descriptor in ipairs(config.dependencies) do
    local dependency = vim.tbl_extend("force", {}, descriptor, { commit = commit })
    local path = root .. "/" .. dependency.path
    table.insert(dependencies, dependency)
    lock[dependency.name] = { branch = dependency.ref, commit = commit }
    by_path[path] = dependency
  end
  local stat = function(path)
    if by_path[path] then return { type = "directory" } end
    if path:sub(-9) == "/doc/tags" then return { type = "file" } end
  end
  local runner = function(arguments)
    local dependency = by_path[arguments[2]]
    if arguments[3] == "config" then return { code = 0, stdout = dependency.url } end
    if arguments[3] == "rev-parse" then return { code = 0, stdout = dependency.commit } end
    return { code = 0, stdout = "!! doc/tags\n" }
  end
  assert.is_true(
    config.validate_staged_repositories(dependencies, lock, root, runner, stat, "/repository", function() end)
  )
  local duplicate = vim.deepcopy(dependencies)
  table.insert(duplicate, vim.deepcopy(dependencies[1]))
  assert.is_false(
    config.validate_staged_repositories(duplicate, lock, root, runner, stat, "/repository", function() end)
  )
  local unmanaged = vim.deepcopy(lock)
  unmanaged.unmanaged = { branch = "main", commit = commit }
  assert.is_false(
    config.validate_staged_repositories(dependencies, unmanaged, root, runner, stat, "/repository", function() end)
  )
  assert.is_false(config.validate_staged_repositories({}, {}, root, runner, stat, "/repository", function() end))
  assert.is_false(
    config.validate_staged_repositories(
      dependencies,
      lock,
      root,
      runner,
      stat,
      "/repository",
      function() return root .. "/link" end
    )
  )
end

T["AUI-HARNESS-LOCK-01 rejects timeout, acquisition errors, symbolic links, and non-directories"] = function()
  local function expect_lock_error(filesystem, expected)
    local ok, message = pcall(environment.with_lifecycle_lock, filesystem, "/lock", function() end, { timeout_ns = 0 })
    assert.is_false(ok)
    assert.is_true(message:find(expected, 1, true) ~= nil)
  end

  expect_lock_error({
    mkdir = function() return nil, "EEXIST" end,
    lstat = function() return { type = "directory" } end,
    now = function() return 0 end,
    wait = function() end,
  }, "Timed out waiting for test environment lock: /lock")
  expect_lock_error({
    mkdir = function() return nil, "EACCES" end,
    now = function() return 0 end,
  }, "Failed to acquire test environment lock: EACCES")
  expect_lock_error({
    mkdir = function() return nil, "EEXIST" end,
    lstat = function() return { type = "link" } end,
    now = function() return 0 end,
    wait = function() end,
  }, "Test environment lock is a symbolic link: /lock")
  expect_lock_error({
    mkdir = function() return nil, "EEXIST" end,
    lstat = function() return { type = "file" } end,
    now = function() return 0 end,
    wait = function() end,
  }, "Test environment lock is not a directory: /lock")
end

T["AUI-HARNESS-06 lifecycle lock retries and cleanup rejects symlinks"] = function()
  local attempts, entries =
    0, { ["/repository/.tests"] = { type = "directory" }, ["/repository/.tests/link"] = { type = "link" } }
  local filesystem = {
    lstat = function(path) return entries[path] end,
    mkdir = function(path)
      attempts = attempts + 1
      if attempts == 1 then return nil, "EEXIST" end
      entries[path] = { type = "directory" }
      return true
    end,
    rmdir = function(path)
      entries[path] = nil
      return true
    end,
    unlink = function(path)
      entries[path] = nil
      return true
    end,
    scandir = function(path) return path == "/repository/.tests" and { "link" } or {} end,
    now = function() return 0 end,
    wait = function() end,
  }
  assert.equals("ok", environment.with_lifecycle_lock(filesystem, "/lock", function() return "ok" end))
  local ok, message = pcall(environment.clear_test_environment, filesystem, "/repository")
  assert.is_false(ok)
  assert.is_true(message:find "symbolic%-link" ~= nil)
end

T["AUI-HARNESS-07 aggregates callback and lifecycle cleanup errors"] = function()
  local ok, message = pcall(environment.with_lifecycle_lock, {
    lstat = function() end,
    mkdir = function() return true end,
    rmdir = function() return nil, "EACCES" end,
    now = function() return 0 end,
    wait = function() end,
  }, "/lock", function() error("callback failure", 0) end)
  assert.is_false(ok)
  assert.is_true(message:find("callback failure", 1, true) ~= nil)
  assert.is_true(message:find("Failed to release", 1, true) ~= nil)
end

return T
