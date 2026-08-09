local MiniTest = require "mini.test"
local config = require "config"

local M = {}
local cases = setmetatable({}, { __mode = "k" })
local unset_environment_value = {}

local function cleanup_error(value) return type(value) == "string" and value or vim.inspect(value) end

local function remove_root(root)
  if vim.fn.delete(root, "rf") ~= 0 then return "Failed to delete child fixture root: " .. root end
end

local function make_case()
  local template = vim.fs.joinpath(vim.uv.os_tmpdir() or vim.fn.stdpath "cache", "astroui-test.XXXXXX")
  local root = assert(vim.uv.fs_mkdtemp(template))
  local paths = {
    root = root,
    config = root .. "/config",
    data = root .. "/data",
    state = root .. "/state",
    cache = root .. "/cache",
    runtime = root .. "/runtime",
  }
  local ok, failure = xpcall(function()
    for _, path in pairs(paths) do
      if path ~= root and vim.fn.mkdir(path, "p", 448) == 0 and vim.fn.isdirectory(path) == 0 then
        error("Cannot create child fixture directory: " .. path, 0)
      end
    end
  end, debug.traceback)
  if not ok then
    local cleanup = remove_root(root)
    if cleanup then failure = failure .. "\n" .. cleanup end
    error(failure, 0)
  end
  return paths
end

local function child_environment(case, additions)
  return vim.tbl_extend("force", {
    XDG_CONFIG_HOME = case.config,
    XDG_DATA_HOME = case.data,
    XDG_STATE_HOME = case.state,
    XDG_CACHE_HOME = case.cache,
    XDG_RUNTIME_DIR = case.runtime,
    ASTROUI_TEST_ROOT = config.root,
    ASTROUI_TEST_ENVIRONMENT = config.test_root,
    LAZY_OFFLINE = "1",
  }, additions or {})
end

local function append_error(errors, prefix, callback)
  local ok, result = pcall(callback)
  if not ok then table.insert(errors, prefix .. cleanup_error(result)) end
  return ok, result
end

local function restore_environment(snapshot, errors)
  for name, value in pairs(snapshot) do
    append_error(errors, "Failed to restore parent environment: ", function()
      if value == unset_environment_value then
        vim.env[name] = nil
      else
        vim.env[name] = value
      end
    end)
  end
end

local function with_parent_environment(environment, snapshot, callback)
  local ok, result = xpcall(function()
    for name, value in pairs(environment) do
      vim.env[name] = value
    end
    return callback()
  end, debug.traceback)
  local errors = {}
  restore_environment(snapshot, errors)
  if not ok then
    if #errors > 0 then result = result .. "\n" .. table.concat(errors, "\n") end
    error(result, 0)
  end
  if #errors > 0 then error(table.concat(errors, "\n"), 0) end
  return result
end

function M.child_job_id(child)
  if type(child) ~= "table" then return nil end
  if type(child.job) == "number" then return child.job end
  if type(child.job) == "table" and type(child.job.id) == "number" then return child.job.id end
end

local function stop_child_process(child, errors)
  if not child then return end
  local running_ok, running = append_error(
    errors,
    "Cannot inspect child Neovim process: ",
    function() return child:is_running() end
  )
  if running_ok and running then
    append_error(errors, "Cannot stop child Neovim process: ", function() child:stop() end)
  end
  local job_id = M.child_job_id(child)
  if not job_id then return end
  local waited_ok, waited = append_error(
    errors,
    "Cannot wait for child Neovim process: ",
    function() return vim.fn.jobwait({ job_id }, 1000) end
  )
  if not waited_ok or type(waited) ~= "table" or waited[1] ~= -1 then return end
  append_error(errors, "Cannot force-stop child Neovim process: ", function() vim.fn.jobstop(job_id) end)
  local stopped_ok, stopped = append_error(
    errors,
    "Cannot verify child Neovim shutdown: ",
    function() return vim.fn.jobwait({ job_id }, 1000) end
  )
  if stopped_ok and (type(stopped) ~= "table" or stopped[1] == -1) then
    table.insert(errors, "Child Neovim process survived shutdown")
  end
end

function M.start_child(additions)
  local case = make_case()
  local environment = child_environment(case, additions)
  local snapshot = {}
  for name in pairs(environment) do
    snapshot[name] = vim.env[name] or unset_environment_value
  end
  local child
  local ok, failure = xpcall(function()
    child = MiniTest.new_child_neovim()
    with_parent_environment(
      environment,
      snapshot,
      function()
        child.start {
          "--cmd",
          "set noswapfile",
          "-u",
          config.fixture_init,
          "--cmd",
          "cd " .. vim.fn.fnameescape(config.root),
        }
      end
    )
    cases[child] = { paths = case, snapshot = snapshot }
    child.lua [[vim.g.astroui_fixture_environment = vim.env.XDG_CONFIG_HOME]]
  end, debug.traceback)
  if not ok then
    local errors = { failure }
    stop_child_process(child, errors)
    append_error(errors, "Failed to delete child fixture root: ", function()
      local cleanup = remove_root(case.root)
      if cleanup then error(cleanup, 0) end
    end)
    error(table.concat(errors, "\n"), 0)
  end
  return child
end

function M.wait_until(child, expression, description, timeout)
  local ready = vim.wait(timeout or config.child_timeout, function()
    local ok, value = pcall(child.lua_get, expression)
    return ok and value == true
  end, 20)
  assert(ready, "Timed out waiting for " .. description)
end

function M.stop_child(child)
  if not child then return end
  local case = cases[child]
  local errors = {}
  stop_child_process(child, errors)
  if case then
    restore_environment(case.snapshot, errors)
    append_error(errors, "Failed to delete child fixture root: ", function()
      local cleanup = remove_root(case.paths.root)
      if cleanup then error(cleanup, 0) end
    end)
  end
  cases[child] = nil
  if #errors > 0 then error(table.concat(errors, "\n"), 0) end
end

return M
