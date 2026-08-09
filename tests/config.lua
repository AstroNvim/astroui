local environment = require "test_environment"

local M = {}

local function normalize(path) return vim.fs.normalize(path):gsub("/$", "") end
local function canonical(path) return assert(vim.uv.fs_realpath(path), "Cannot resolve repository root: " .. path) end

M.root = normalize(canonical(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))))
M.dependencies = {
  {
    name = "lazy.nvim",
    repository = "folke/lazy.nvim",
    url = "https://github.com/folke/lazy.nvim.git",
    ref = "stable",
    path = "lazy.nvim",
  },
  {
    name = "astrocore",
    repository = "AstroNvim/astrocore",
    url = "https://github.com/AstroNvim/astrocore.git",
    ref = "main",
    path = "data/nvim/lazy/astrocore",
  },
  {
    name = "mini.test",
    repository = "echasnovski/mini.test",
    url = "https://github.com/echasnovski/mini.test.git",
    ref = "main",
    path = "data/nvim/lazy/mini.test",
  },
  {
    name = "luassert",
    repository = "lunarmodules/luassert",
    url = "https://github.com/lunarmodules/luassert.git",
    ref = "master",
    path = "data/nvim/lazy/luassert",
  },
  {
    name = "say",
    repository = "Olivine-Labs/say",
    url = "https://github.com/Olivine-Labs/say.git",
    ref = "master",
    path = "data/nvim/lazy/say",
  },
  {
    name = "heirline.nvim",
    repository = "rebelot/heirline.nvim",
    url = "https://github.com/rebelot/heirline.nvim.git",
    ref = "master",
    path = "data/nvim/lazy/heirline.nvim",
  },
}
M.validation_requirements = {
  dependencies = M.dependencies,
  copied_libraries = {
    luassert = "lua/luassert",
    say = "lua/say",
  },
}

local fingerprint_input = table.concat({
  "schema=3",
  "sha256=sha256",
  "layout=lazy.nvim,data/nvim/lazy,lua,manifest.json,lazy-lock.json,.ready",
  "copied=luassert:src;say:src/say",
  "untracked=doc/tags:file",
  "lazy.nvim|folke/lazy.nvim|https://github.com/folke/lazy.nvim.git|stable",
  "astrocore|AstroNvim/astrocore|https://github.com/AstroNvim/astrocore.git|main",
  "mini.test|echasnovski/mini.test|https://github.com/echasnovski/mini.test.git|main",
  "luassert|lunarmodules/luassert|https://github.com/lunarmodules/luassert.git|master",
  "say|Olivine-Labs/say|https://github.com/Olivine-Labs/say.git|master",
  "heirline.nvim|rebelot/heirline.nvim|https://github.com/rebelot/heirline.nvim.git|master",
}, "\n")
M.fingerprint = vim.fn.sha256(fingerprint_input)
M.fixture_init = M.root .. "/tests/fixtures/init.lua"
M.child_timeout = 10000

local paths = environment.paths(M.root)
for name, value in pairs(paths) do
  M[name] = value
end

local function read_json(path)
  local file, open_error = io.open(path, "rb")
  if not file then return nil, open_error end
  local ok, value = pcall(vim.json.decode, file:read "*a")
  file:close()
  return ok and value or nil, value
end

local function lstat(path) return vim.uv.fs_lstat(path) end
local function entry_type(entry) return type(entry) == "table" and entry.type or entry end

local function git(arguments)
  return vim
    .system(
      vim.list_extend({ "git" }, arguments),
      { text = true, env = vim.tbl_extend("force", vim.fn.environ(), { GIT_OPTIONAL_LOCKS = "0" }) }
    )
    :wait()
end

function M.validate_repository(dependency, commit, runner, stat, root, repository_root, find_tree_symlink)
  runner, stat, root = runner or git, stat or lstat, root or M.test_root
  repository_root = repository_root or M.root
  local path = root .. "/" .. dependency.path
  if not environment.has_safe_path_type(repository_root, path, "directory", stat) then
    return false, "unsafe dependency path: " .. dependency.name
  end
  find_tree_symlink = find_tree_symlink or environment.find_tree_symlink
  local symlink = find_tree_symlink(path, stat)
  if symlink then return false, "dependency contains a symbolic link: " .. dependency.name end
  local origin = runner { "-C", path, "config", "--get", "remote.origin.url" }
  local head = runner { "-C", path, "rev-parse", "HEAD" }
  local status = runner { "-C", path, "status", "--porcelain=v1", "--ignored", "--untracked-files=all" }
  if origin.code ~= 0 or vim.trim(origin.stdout) ~= dependency.url then
    return false, "unexpected dependency origin: " .. dependency.name
  end
  if head.code ~= 0 or vim.trim(head.stdout) ~= commit then
    return false, "unexpected dependency HEAD: " .. dependency.name
  end
  if status.code ~= 0 then return false, "cannot inspect dependency status: " .. dependency.name end
  local ignored_tags = 0
  for line in status.stdout:gmatch "[^\r\n]+" do
    local path_status = line:sub(4)
    if line:sub(1, 2) ~= "!!" or path_status ~= "doc/tags" or entry_type(stat(path .. "/doc/tags")) ~= "file" then
      return false, "dependency is modified, untracked, or unsafe: " .. dependency.name
    end
    ignored_tags = ignored_tags + 1
    if ignored_tags > 1 then return false, "dependency has duplicate ignored tags: " .. dependency.name end
  end
  return true
end

function M.validate_staged_repositories(dependencies, lock, root, runner, stat, repository_root, find_tree_symlink)
  stat, root = stat or lstat, root or M.test_root
  repository_root = repository_root or M.root
  find_tree_symlink = find_tree_symlink or environment.find_tree_symlink
  local metadata_valid, metadata_error =
    environment.validate_dependencies({ dependencies = dependencies }, lock, M.validation_requirements, root, stat)
  if not metadata_valid then return false, metadata_error end
  local symlink = find_tree_symlink(root, stat)
  if symlink then return false, "staged test environment contains a symbolic link: " .. symlink end
  for _, dependency in ipairs(dependencies) do
    local repository_valid, repository_error =
      M.validate_repository(dependency, dependency.commit, runner, stat, root, repository_root, find_tree_symlink)
    if not repository_valid then return false, repository_error end
  end
  return true
end

function M.validate_ready_environment()
  local symlink = environment.find_tree_symlink(M.test_root)
  if symlink then return false, "test environment contains a symbolic link: " .. symlink end
  for _, file in ipairs { M.ready, M.manifest, M.lockfile } do
    if not environment.has_safe_path_type(M.root, file, "file", lstat) then
      return false, "missing lifecycle file: " .. file
    end
  end
  local marker, marker_error = read_json(M.ready)
  local manifest, manifest_error = read_json(M.manifest)
  local lock, lock_error = read_json(M.lockfile)
  if not marker then return false, "cannot read .ready: " .. tostring(marker_error) end
  if not manifest then return false, "cannot read manifest: " .. tostring(manifest_error) end
  if not lock then return false, "cannot read lockfile: " .. tostring(lock_error) end
  local valid, message =
    environment.validate_ready(marker, manifest, lock, M.fingerprint, M.test_root, lstat, M.validation_requirements)
  if not valid then return false, message end
  for index, dependency in ipairs(M.dependencies) do
    local recorded = manifest.dependencies[index]
    if
      not recorded
      or recorded.name ~= dependency.name
      or recorded.repository ~= dependency.repository
      or recorded.url ~= dependency.url
      or recorded.ref ~= dependency.ref
      or recorded.path ~= dependency.path
    then
      return false, "managed dependency descriptor differs"
    end
    local repository_valid, repository_error = M.validate_repository(dependency, recorded.commit)
    if not repository_valid then return false, repository_error end
  end
  return true
end

function M.assert_ready_environment()
  local valid, message = M.validate_ready_environment()
  if not valid then
    error("Test environment is incomplete or incompatible. Run `make test-clear` then retry: " .. message, 0)
  end
end

return M
