local MiniTest = require "mini.test"
local child_helpers = require "helpers"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

T["AUI-UNIT-HELPERS-01 with_module restores package and Vim state after scheduled work"] = function()
  local original_notify = vim.notify
  local original_schedule = vim.schedule
  package.preload["astroui.test.module"] = function()
    vim.schedule(function() vim.g.astroui_harness_scheduled = true end)
    return {}
  end
  helpers.with_module("astroui.test.module", { notify = function() end }, function() require "astroui.test.module" end)
  assert.is_true(vim.g.astroui_harness_scheduled)
  assert.equals(original_notify, vim.notify)
  assert.equals(original_schedule, vim.schedule)
  package.preload["astroui.test.module"] = nil
  vim.g.astroui_harness_scheduled = nil
end

T["AUI-UNIT-HELPERS-02 with_module preserves callback and cleanup failures"] = function()
  local module_name = "astroui.test.cleanup_failure"
  local original_notify = vim.notify
  local original_schedule = vim.schedule
  package.preload[module_name] = function() return {} end
  local ok, message = pcall(helpers.with_module, module_name, {}, function()
    vim.schedule(function() error("scheduled cleanup failure", 0) end)
    error("callback failure", 0)
  end)
  assert.is_false(ok)
  assert.is_true(message:find("callback failure", 1, true) ~= nil)
  assert.is_true(message:find("scheduled cleanup failure", 1, true) ~= nil)
  assert.equals(original_notify, vim.notify)
  assert.equals(original_schedule, vim.schedule)
  package.preload[module_name] = nil
end

T["AUI-HARNESS-08 child helper restores set and unset parent environment values"] = function()
  assert.equals(42, child_helpers.child_job_id { job = 42 })
  assert.equals(43, child_helpers.child_job_id { job = { id = 43 } })
  assert.is_nil(child_helpers.child_job_id { job = {} })
  local original_xdg = vim.env.XDG_CONFIG_HOME
  local original_test_root = vim.env.ASTROUI_TEST_ROOT
  local original_extra = vim.env.ASTROUI_CHILD_EXTRA
  vim.env.ASTROUI_TEST_ROOT = nil
  vim.env.ASTROUI_CHILD_EXTRA = nil

  local child
  local ok, result = xpcall(function()
    child = child_helpers.start_child { ASTROUI_CHILD_EXTRA = "child-only" }
    assert.is_true(child:is_running())
    assert.not_equals(original_xdg, child.lua_get "vim.env.XDG_CONFIG_HOME")
    assert.is_string(child.lua_get "vim.env.ASTROUI_TEST_ROOT")
    assert.equals("child-only", child.lua_get "vim.env.ASTROUI_CHILD_EXTRA")
    assert.is_nil(vim.env.ASTROUI_TEST_ROOT)
    assert.is_nil(vim.env.ASTROUI_CHILD_EXTRA)
  end, debug.traceback)
  local stopped, stop_error = pcall(child_helpers.stop_child, child)
  local restored_xdg = vim.env.XDG_CONFIG_HOME
  local restored_test_root = vim.env.ASTROUI_TEST_ROOT
  local restored_extra = vim.env.ASTROUI_CHILD_EXTRA
  vim.env.ASTROUI_TEST_ROOT = original_test_root
  vim.env.ASTROUI_CHILD_EXTRA = original_extra

  if not ok then error(result, 0) end
  if not stopped then error(stop_error, 0) end
  assert.equals(original_xdg, restored_xdg)
  assert.is_nil(restored_test_root)
  assert.is_nil(restored_extra)
end

T["AUI-HARNESS-09 with_module removes and restores package entries"] = function()
  local module_name = "astroui.test.removed"
  local dependency_name = "astroui.test.dependency"
  local original_dependency = { original = true }
  package.loaded[dependency_name] = original_dependency
  package.preload[module_name] = function() return {} end

  helpers.with_module(
    module_name,
    { loaded = { [dependency_name] = helpers.remove } },
    function() assert.is_nil(package.loaded[dependency_name]) end
  )

  assert.equals(original_dependency, package.loaded[dependency_name])
  package.loaded[dependency_name] = nil
  package.preload[module_name] = nil
end

T["AUI-HARNESS-10 child startup cleanup preserves parent environment and failures"] = function()
  local original_factory = MiniTest.new_child_neovim
  local original_environment = vim.env.XDG_CONFIG_HOME
  MiniTest.new_child_neovim = function()
    return {
      start = function() error("child start failure", 0) end,
      is_running = function() error("child cleanup failure", 0) end,
    }
  end
  local ok, message = pcall(child_helpers.start_child)
  MiniTest.new_child_neovim = original_factory
  assert.is_false(ok)
  assert.is_true(message:find("child start failure", 1, true) ~= nil)
  assert.is_true(message:find("child cleanup failure", 1, true) ~= nil)
  assert.equals(original_environment, vim.env.XDG_CONFIG_HOME)
end

return T
