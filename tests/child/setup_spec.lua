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

T["AUI-CHILD-SETUP-01 applies configured highlights in order and emits AstroColorScheme"] = function()
  with_child(function(child)
    child.lua [[
      local astroui = require "astroui"
      vim.g.aui_colorscheme_events = 0
      vim.api.nvim_create_autocmd("User", {
        pattern = "AstroColorScheme",
        callback = function() vim.g.aui_colorscheme_events = vim.g.aui_colorscheme_events + 1 end,
      })
      astroui.setup {
        highlights = {
          init = {
            AUIChildInit = { bg = "#112233" },
            AUIChildOrder = { fg = "#111111" },
          },
          aui_child_scheme = function(name)
            vim.g.aui_highlight_function_name = name
            return { AUIChildOrder = { fg = "#222222" } }
          end,
        },
      }
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "aui_child_missing", modeline = false })
      vim.g.colors_name = "aui_child_scheme"
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "aui_child_scheme", modeline = false })
      local init_highlight = vim.api.nvim_get_hl(0, { name = "AUIChildInit", link = false })
      local order_highlight = vim.api.nvim_get_hl(0, { name = "AUIChildOrder", link = false })
      vim.g.aui_child_highlights_ok = vim.g.aui_colorscheme_events == 2
        and vim.g.aui_highlight_function_name == "aui_child_scheme"
        and init_highlight.bg == tonumber("112233", 16)
        and order_highlight.fg == tonumber("222222", 16)
    ]]

    assert.equals(true, child.lua_get "vim.g.aui_child_highlights_ok")
  end)
end

T["AUI-CHILD-SETUP-02 replaces the highlight augroup on repeated setup"] = function()
  with_child(function(child)
    child.lua [[
      local astroui = require "astroui"
      vim.g.aui_replacement_events = 0
      vim.api.nvim_create_autocmd("User", {
        pattern = "AstroColorScheme",
        callback = function() vim.g.aui_replacement_events = vim.g.aui_replacement_events + 1 end,
      })
      astroui.setup { highlights = { init = { AUIChildFirst = { fg = "#111111" } } } }
      astroui.setup { highlights = { init = { AUIChildSecond = { fg = "#222222" } } } }
      vim.g.colors_name = "aui_child_replacement"
      vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "aui_child_replacement", modeline = false })
      vim.g.aui_replacement_ok = vim.g.aui_replacement_events == 1
        and vim.api.nvim_get_hl(0, { name = "AUIChildSecond", link = false }).fg == tonumber("222222", 16)
    ]]

    assert.equals(true, child.lua_get "vim.g.aui_replacement_ok")
  end)
end

return T
