local MiniTest = require "mini.test"
local helpers = require "helpers"

local T = MiniTest.new_set()

local function with_child(callback)
  local child = helpers.start_child()
  local ok, result = xpcall(function() return callback(child) end, debug.traceback)
  local stopped, stop_error = pcall(helpers.stop_child, child)
  if not ok then error(result, 0) end
  if not stopped then error(stop_error, 0) end
  return result
end

T["AUI-CHILD-FFI-01 uses the supported foldcolumn implementation for this Neovim version"] = function()
  with_child(
    function(child)
      child.lua [[
      local provider = require "astroui.status.provider"

      if vim.fn.has "nvim-0.12" == 1 then
        local original_preload = package.preload["astroui.ffi"]
        package.loaded["astroui.ffi"] = nil
        package.preload["astroui.ffi"] = function() error "Neovim 0.12 foldcolumn must bypass AstroUI FFI" end
        local ok, renderer = pcall(provider.foldcolumn)
        package.preload["astroui.ffi"] = original_preload

        assert(ok, renderer)
        assert(renderer == "%C")
        assert(package.loaded["astroui.ffi"] == nil)
      elseif vim.fn.has "nvim-0.11" == 1 then
        local ffi = require "astroui.ffi"
        assert(type(ffi) == "table")
        assert(type(ffi.C) == "userdata")

        local renderer = provider.foldcolumn()
        assert(type(renderer) == "function")

        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first", "  second" })
        vim.wo.foldcolumn = "1"
        assert(vim.wo.foldcolumn == "1")

        local ok, rendered = pcall(renderer)
        assert(ok, rendered)
        assert(type(rendered) == "string")
      else
        error("AUI-CHILD-FFI-01 requires Neovim 0.11 or newer")
      end
    ]]
    end
  )
end

return T
