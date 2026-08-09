local MiniTest = require "mini.test"
local child_helpers = require "helpers"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

T["AUI-UNIT-HELPERS-01 with_module restores package and Vim state after scheduled work"] = function()
  local original_notify = vim.notify
  local original_schedule = vim.schedule
  local original_preload = package.preload["astroui.test.module"]
  local original_scheduled = vim.g.astroui_harness_scheduled
  helpers.with_finalizer(function()
    package.preload["astroui.test.module"] = function()
      vim.schedule(function() vim.g.astroui_harness_scheduled = true end)
      return {}
    end
    helpers.with_module(
      "astroui.test.module",
      { notify = function() end },
      function() require "astroui.test.module" end
    )
    assert.is_true(vim.g.astroui_harness_scheduled)
    assert.equals(original_notify, vim.notify)
    assert.equals(original_schedule, vim.schedule)
  end, function()
    package.preload["astroui.test.module"] = original_preload
    vim.g.astroui_harness_scheduled = original_scheduled
  end)
  assert.equals(original_notify, vim.notify)
  assert.equals(original_schedule, vim.schedule)
  assert.equals(original_preload, package.preload["astroui.test.module"])
  assert.equals(original_scheduled, vim.g.astroui_harness_scheduled)
end

T["AUI-UNIT-HELPERS-02 with_module preserves callback and cleanup failures"] = function()
  local module_name = "astroui.test.cleanup_failure"
  local original_notify = vim.notify
  local original_schedule = vim.schedule
  local original_preload = package.preload[module_name]
  helpers.with_finalizer(function()
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
  end, function() package.preload[module_name] = original_preload end)
  assert.equals(original_preload, package.preload[module_name])
end

T["AUI-UNIT-HELPERS-03 with_finalizer preserves callback results and cleanup failures"] = function()
  local finalized = false
  assert.equals(
    "callback result",
    helpers.with_finalizer(function() return "callback result" end, function() finalized = true end)
  )
  assert.is_true(finalized)

  local cleanup_ok, cleanup_error = pcall(
    helpers.with_finalizer,
    function() return "callback result" end,
    function() error("cleanup failure", 0) end
  )
  assert.is_false(cleanup_ok)
  assert.is_true(cleanup_error:find("Cleanup failed: cleanup failure", 1, true) ~= nil)

  local both_ok, both_error = pcall(
    helpers.with_finalizer,
    function() error("callback failure", 0) end,
    function() error("cleanup failure", 0) end
  )
  assert.is_false(both_ok)
  assert.is_true(both_error:find("callback failure", 1, true) ~= nil)
  assert.is_true(both_error:find("Cleanup failed: cleanup failure", 1, true) ~= nil)
end

T["AUI-HARNESS-08 child helper restores set and unset parent environment values"] = function()
  assert.equals(42, child_helpers.child_job_id { job = 42 })
  assert.equals(43, child_helpers.child_job_id { job = { id = 43 } })
  assert.is_nil(child_helpers.child_job_id { job = {} })
  local original_xdg = vim.env.XDG_CONFIG_HOME
  local original_test_root = vim.env.ASTROUI_TEST_ROOT
  local original_extra = vim.env.ASTROUI_CHILD_EXTRA
  local child
  local restored_xdg, restored_test_root, restored_extra
  helpers.with_finalizer(function()
    vim.env.ASTROUI_TEST_ROOT = nil
    vim.env.ASTROUI_CHILD_EXTRA = nil
    child = child_helpers.start_child { ASTROUI_CHILD_EXTRA = "child-only" }
    assert.is_true(child:is_running())
    assert.not_equals(original_xdg, child.lua_get "vim.env.XDG_CONFIG_HOME")
    assert.is_string(child.lua_get "vim.env.ASTROUI_TEST_ROOT")
    assert.equals("child-only", child.lua_get "vim.env.ASTROUI_CHILD_EXTRA")
    assert.is_nil(vim.env.ASTROUI_TEST_ROOT)
    assert.is_nil(vim.env.ASTROUI_CHILD_EXTRA)
  end, function()
    local stopped, stop_error = pcall(child_helpers.stop_child, child)
    restored_xdg = vim.env.XDG_CONFIG_HOME
    restored_test_root = vim.env.ASTROUI_TEST_ROOT
    restored_extra = vim.env.ASTROUI_CHILD_EXTRA
    vim.env.ASTROUI_TEST_ROOT = original_test_root
    vim.env.ASTROUI_CHILD_EXTRA = original_extra
    if not stopped then error(stop_error, 0) end
  end)
  assert.equals(original_xdg, restored_xdg)
  assert.is_nil(restored_test_root)
  assert.is_nil(restored_extra)
end

T["AUI-HARNESS-09 with_module removes and restores package entries"] = function()
  local module_name = "astroui.test.removed"
  local dependency_name = "astroui.test.dependency"
  local original_module_preload = package.preload[module_name]
  local original_loaded_dependency = package.loaded[dependency_name]
  local fixture_dependency = { original = true }
  helpers.with_finalizer(function()
    package.loaded[dependency_name] = fixture_dependency
    package.preload[module_name] = function() return {} end

    helpers.with_module(
      module_name,
      { loaded = { [dependency_name] = helpers.remove } },
      function() assert.is_nil(package.loaded[dependency_name]) end
    )

    assert.equals(fixture_dependency, package.loaded[dependency_name])
  end, function()
    package.loaded[dependency_name] = original_loaded_dependency
    package.preload[module_name] = original_module_preload
  end)
  assert.equals(original_loaded_dependency, package.loaded[dependency_name])
  assert.equals(original_module_preload, package.preload[module_name])
end

T["AUI-HARNESS-10 child startup cleanup preserves parent environment and failures"] = function()
  local original_factory = MiniTest.new_child_neovim
  local original_environment = vim.env.XDG_CONFIG_HOME
  local original_jobwait = vim.fn.jobwait
  local original_jobstop = vim.fn.jobstop
  helpers.with_finalizer(function()
    local factory = function()
      return {
        start = function() error("child start failure", 0) end,
        is_running = function() error("child cleanup failure", 0) end,
      }
    end
    local jobwait = original_jobwait
    local jobstop = original_jobstop
    MiniTest.new_child_neovim = function() return factory() end
    vim.fn.jobwait = function(job_ids, timeout) return jobwait(job_ids, timeout) end
    vim.fn.jobstop = function(job_id) return jobstop(job_id) end
    local ok, message = pcall(child_helpers.start_child)
    assert.is_false(ok)
    assert.is_true(message:find("child start failure", 1, true) ~= nil)
    assert.is_true(message:find("child cleanup failure", 1, true) ~= nil)

    factory = function()
      return {
        job = 42,
        start = function() error("child start failure", 0) end,
        is_running = function() return false end,
      }
    end
    jobwait = function(_, _) error("jobwait failure", 0) end
    ok, message = pcall(child_helpers.start_child)
    assert.is_false(ok)
    assert.is_true(message:find("Cannot wait for child Neovim process: jobwait failure", 1, true) ~= nil)

    local force_stops, waits = 0, 0
    factory = function()
      return {
        job = 43,
        start = function() error("child start failure", 0) end,
        is_running = function() return true end,
        stop = function() end,
      }
    end
    jobwait = function(_, _)
      waits = waits + 1
      return { -1 }
    end
    jobstop = function(_)
      force_stops = force_stops + 1
      return 1
    end
    ok, message = pcall(child_helpers.start_child)
    assert.is_false(ok)
    assert.is_true(message:find("child start failure", 1, true) ~= nil)
    assert.is_true(message:find("Child Neovim process survived shutdown", 1, true) ~= nil)
    assert.equals(1, force_stops)
    assert.equals(2, waits)
  end, function()
    MiniTest.new_child_neovim = original_factory
    vim.fn.jobwait = original_jobwait
    vim.fn.jobstop = original_jobstop
  end)
  assert.equals(original_environment, vim.env.XDG_CONFIG_HOME)
  assert.equals(original_factory, MiniTest.new_child_neovim)
  assert.equals(original_jobwait, vim.fn.jobwait)
  assert.equals(original_jobstop, vim.fn.jobstop)
end

return T
