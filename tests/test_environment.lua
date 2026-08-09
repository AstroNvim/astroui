local M = {}

M.schema = 3
M.sha256_algorithm = "sha256"

local function entry_type(entry)
  if type(entry) == "string" then return entry end
  return type(entry) == "table" and entry.type or nil
end

function M.is_safe_relative_path(path)
  if type(path) ~= "string" or path == "" or path:sub(1, 1) == "/" or path:match "^[A-Za-z]:" then return false end
  if path:find("\\", 1, true) or path:find("//", 1, true) or path:sub(-1) == "/" then return false end
  for part in path:gmatch "[^/]+" do
    if part == "." or part == ".." then return false end
  end
  return true
end

function M.find_symlink_component(root, path, lstat)
  if type(root) ~= "string" or type(path) ~= "string" or type(lstat) ~= "function" then return path end
  local prefix = root .. "/"
  if path ~= root and path:sub(1, #prefix) ~= prefix then return path end
  local current = root
  if entry_type(lstat(current)) == "link" then return current end
  for part in path:sub(#prefix + 1):gmatch "[^/]+" do
    current = current .. "/" .. part
    if entry_type(lstat(current)) == "link" then return current end
  end
end

function M.has_safe_path_type(root, path, expected, lstat)
  return M.find_symlink_component(root, path, lstat) == nil and entry_type(lstat(path)) == expected
end

function M.find_tree_symlink(path, lstat, scandir, next_entry)
  lstat = lstat or vim.uv.fs_lstat
  scandir = scandir or vim.uv.fs_scandir
  next_entry = next_entry or vim.uv.fs_scandir_next
  local entry = lstat(path)
  if not entry then return nil end
  if entry_type(entry) == "link" then return path end
  if entry_type(entry) ~= "directory" then return path end
  local scanner = scandir(path)
  if not scanner then return path end
  while true do
    local name = next_entry(scanner)
    if not name then break end
    local child = path .. "/" .. name
    local child_entry = lstat(child)
    if entry_type(child_entry) == "link" then return child end
    if entry_type(child_entry) == "directory" then
      local nested = M.find_tree_symlink(child, lstat, scandir, next_entry)
      if nested then return nested end
    end
  end
end

function M.paths_for_test_root(test_root)
  return {
    test_root = test_root,
    lazy_path = test_root .. "/lazy.nvim",
    plugin_root = test_root .. "/data/nvim/lazy",
    test_lua_dir = test_root .. "/lua",
    lockfile = test_root .. "/lazy-lock.json",
    manifest = test_root .. "/manifest.json",
    ready = test_root .. "/.ready",
    shared_data_dir = test_root .. "/data/nvim",
    state_dir = test_root .. "/state",
    cache_dir = test_root .. "/cache",
  }
end

function M.paths(root)
  local paths = {
    root = root,
    test_root = root .. "/.tests",
    staging_root = root .. "/.tests.bootstrap",
    prepare_lock = root .. "/.tests.prepare.lock",
  }
  for name, value in pairs(M.paths_for_test_root(paths.test_root)) do
    paths[name] = value
  end
  return paths
end

function M.classify(paths, lstat)
  if not lstat(paths.test_root) then return "missing" end
  if entry_type(lstat(paths.ready)) == "file" then return "marked" end
  return "unmarked"
end

local function sha256(contents) return vim.fn.sha256(contents) end

local function table_count(value)
  local count = 0
  for _ in pairs(value) do
    count = count + 1
  end
  return count
end

function M.validate_dependencies(manifest, lock, requirements, root, lstat)
  if type(manifest.dependencies) ~= "table" or type(lock) ~= "table" then
    return false, "the manifest or lockfile is invalid"
  end
  local dependencies = manifest.dependencies
  local dependency_count = #dependencies
  if table_count(dependencies) ~= dependency_count then return false, "the dependency list is not an array" end
  local names, paths = {}, {}
  for _, dependency in ipairs(dependencies) do
    if
      type(dependency) ~= "table"
      or type(dependency.name) ~= "string"
      or dependency.name == ""
      or type(dependency.repository) ~= "string"
      or dependency.repository == ""
      or type(dependency.url) ~= "string"
      or dependency.url == ""
      or type(dependency.ref) ~= "string"
      or dependency.ref == ""
      or not M.is_safe_relative_path(dependency.path)
      or type(dependency.commit) ~= "string"
      or #dependency.commit ~= 40
      or not dependency.commit:match "^[0-9a-f]+$"
    then
      return false, "a dependency entry is invalid"
    end
    if names[dependency.name] or paths[dependency.path] then
      return false, "the dependency list has duplicate entries"
    end
    names[dependency.name], paths[dependency.path] = true, true
    if not M.has_safe_path_type(root, root .. "/" .. dependency.path, "directory", lstat) then
      return false, "a dependency path is missing or unsafe: " .. dependency.path
    end
    local locked = lock[dependency.name]
    if type(locked) ~= "table" or locked.commit ~= dependency.commit or locked.branch ~= dependency.ref then
      return false, "the generated lockfile differs"
    end
  end
  if table_count(lock) ~= dependency_count then return false, "the generated lockfile has unmanaged entries" end
  for name in pairs(lock) do
    if type(name) ~= "string" or not names[name] then return false, "the generated lockfile has unmanaged entries" end
  end
  if requirements and requirements.dependencies then
    if #requirements.dependencies ~= dependency_count then return false, "managed dependency set differs" end
    for index, expected in ipairs(requirements.dependencies) do
      local recorded = dependencies[index]
      if
        recorded.name ~= expected.name
        or recorded.repository ~= expected.repository
        or recorded.url ~= expected.url
        or recorded.ref ~= expected.ref
        or recorded.path ~= expected.path
      then
        return false, "managed dependency descriptor differs"
      end
    end
  end
  return true
end

local function inventory_paths(root, directory)
  local paths = {}
  local function visit(path, relative)
    local scanner, scan_error = vim.uv.fs_scandir(path)
    if not scanner then return nil, scan_error end
    while true do
      local name = vim.uv.fs_scandir_next(scanner)
      if not name then break end
      local child_path, child_relative = path .. "/" .. name, relative .. "/" .. name
      local entry = vim.uv.fs_lstat(child_path)
      if not entry or entry.type == "link" then return nil, "unsafe copied library path: " .. child_relative end
      if entry.type == "directory" then
        local valid, error_message = visit(child_path, child_relative)
        if not valid then return nil, error_message end
      elseif entry.type == "file" then
        paths[child_relative] = true
      else
        return nil, "unsupported copied library path: " .. child_relative
      end
    end
    return true
  end
  local valid, error_message = visit(root .. "/" .. directory, directory)
  if not valid then return nil, error_message end
  return paths
end

local function validate_files(root, library, lstat)
  local files = library.files
  if type(files) ~= "table" then return false, "copied library inventory is missing" end
  local seen = {}
  for _, file in ipairs(files) do
    if
      type(file) ~= "table"
      or not M.is_safe_relative_path(file.path)
      or type(file.sha256) ~= "string"
      or #file.sha256 ~= 64
      or not file.sha256:match "^[0-9a-f]+$"
    then
      return false, "copied library inventory is invalid"
    end
    if seen[file.path] then return false, "copied library inventory has duplicate paths" end
    seen[file.path] = true
    local path = root .. "/" .. file.path
    if not M.has_safe_path_type(root, path, "file", lstat) then
      return false, "copied library file is missing or unsafe: " .. file.path
    end
    local handle, open_error = io.open(path, "rb")
    if not handle then return false, "cannot read copied library file: " .. tostring(open_error) end
    local valid = sha256(handle:read "*a") == file.sha256
    handle:close()
    if not valid then return false, "copied library checksum differs: " .. file.path end
  end
  local actual, inventory_error = inventory_paths(root, library.directory)
  if not actual then return false, inventory_error end
  for path in pairs(actual) do
    if not seen[path] then return false, "copied library has an unexpected file: " .. path end
  end
  for path in pairs(seen) do
    if not actual[path] then return false, "copied library inventory has a missing file: " .. path end
  end
  return true
end

function M.validate_ready(marker, manifest, lock, fingerprint, root, lstat, requirements)
  if type(marker) ~= "table" or marker.schema ~= M.schema or marker.fingerprint ~= fingerprint then
    return false, "the .ready marker is incompatible"
  end
  if marker.manifest ~= "manifest.json" or marker.lockfile ~= "lazy-lock.json" then
    return false, "the .ready marker references unexpected files"
  end
  if type(manifest) ~= "table" or manifest.schema ~= M.schema or manifest.fingerprint ~= fingerprint then
    return false, "the manifest is incompatible"
  end
  if manifest.lockfile ~= "lazy-lock.json" then return false, "the manifest or lockfile is invalid" end
  local dependencies_valid, dependency_error = M.validate_dependencies(manifest, lock, requirements, root, lstat)
  if not dependencies_valid then return false, dependency_error end
  if type(manifest.copied_libraries) ~= "table" then return false, "the copied library set is invalid" end
  if requirements and requirements.copied_libraries then
    if table_count(manifest.copied_libraries) ~= table_count(requirements.copied_libraries) then
      return false, "copied library set differs"
    end
    for name, directory in pairs(requirements.copied_libraries) do
      local library = manifest.copied_libraries[name]
      if type(library) ~= "table" or library.directory ~= directory then
        return false, "copied library descriptor differs: " .. name
      end
    end
  end
  for name, library in pairs(manifest.copied_libraries) do
    if type(name) ~= "string" or name == "" then return false, "copied library name is invalid" end
    local valid, message = validate_files(root, library, lstat)
    if not valid then return false, message end
  end
  return true
end

function M.lock_error_is_retryable(error_message)
  local message = tostring(error_message)
  return message:find("EEXIST", 1, true) ~= nil or message:find("already exists", 1, true) ~= nil
end

function M.with_lifecycle_lock(filesystem, lock_path, callback, options)
  options = options or {}
  local deadline = filesystem.now() + (options.timeout_ns or 300000000000)
  while true do
    local created, create_error = filesystem.mkdir(lock_path)
    if created then break end
    if not M.lock_error_is_retryable(create_error) then
      error("Failed to acquire test environment lock: " .. tostring(create_error), 0)
    end
    local entry = filesystem.lstat(lock_path)
    if entry_type(entry) == "link" then error("Test environment lock is a symbolic link: " .. lock_path, 0) end
    if entry and entry_type(entry) ~= "directory" then
      error("Test environment lock is not a directory: " .. lock_path, 0)
    end
    if filesystem.now() >= deadline then error("Timed out waiting for test environment lock: " .. lock_path, 0) end
    filesystem.wait(options.retry_delay_ms or 100)
  end
  local ok, result = xpcall(callback, debug.traceback)
  local released, release_error = filesystem.rmdir(lock_path)
  if not released then
    local message = "Failed to release test environment lock: " .. tostring(release_error)
    if ok then error(message, 0) end
    result = result .. "\n" .. message
  end
  if not ok then error(result, 0) end
  return result
end

function M.remove_tree(filesystem, path)
  local function inspect(current)
    local entry = filesystem.lstat(current)
    if not entry then return true, false end
    if entry_type(entry) == "link" then return false, "refusing to remove a symbolic-link path: " .. current end
    if entry_type(entry) ~= "directory" then
      return false, "refusing to recursively remove a non-directory path: " .. current
    end
    local children, scan_error = filesystem.scandir(current)
    if not children then return false, "failed to scan " .. current .. ": " .. tostring(scan_error) end
    for _, child in ipairs(children) do
      local child_path = current .. "/" .. child
      local child_entry = filesystem.lstat(child_path)
      if entry_type(child_entry) == "link" then
        return false, "refusing to remove a symbolic-link path: " .. child_path
      end
      if entry_type(child_entry) == "directory" then
        local safe, error_message = inspect(child_path)
        if not safe then return false, error_message end
      elseif entry_type(child_entry) ~= "file" then
        return false, "refusing to remove an unsupported path: " .. child_path
      end
    end
    return true, true
  end
  local safe, exists_or_error = inspect(path)
  if not safe or not exists_or_error then return safe, exists_or_error end
  local function remove(current)
    local children, scan_error = filesystem.scandir(current)
    if not children then return false, scan_error end
    for _, child in ipairs(children) do
      local child_path = current .. "/" .. child
      if entry_type(filesystem.lstat(child_path)) == "directory" then
        local removed, remove_error = remove(child_path)
        if not removed then return false, remove_error end
      else
        local removed, remove_error = filesystem.unlink(child_path)
        if not removed then return false, remove_error end
      end
    end
    return filesystem.rmdir(current)
  end
  return remove(path)
end

function M.clear_test_environment(filesystem, root, target)
  local paths = M.paths(root)
  target = target or paths.test_root
  if target ~= paths.test_root or M.find_symlink_component(root, target, filesystem.lstat) then
    error("Refusing to clear a non-canonical or symbolic-link test environment path: " .. target, 0)
  end
  return M.with_lifecycle_lock(filesystem, paths.prepare_lock, function()
    local entry = filesystem.lstat(target)
    if not entry then return false end
    if entry_type(entry) ~= "directory" then
      error("Refusing to clear a non-directory test environment: " .. target, 0)
    end
    local removed, remove_error = M.remove_tree(filesystem, target)
    if not removed then error("Failed to clear test environment: " .. tostring(remove_error), 0) end
    return true
  end)
end

return M
