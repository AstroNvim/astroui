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

T["AUI-CHILD-FOLD-01 configures foldexpr for a real buffer without folding algorithm assertions"] = function()
  with_child(
    function(child)
      child.lua [[
      local astroui = require "astroui"
      astroui.config.folding = { enabled = true, methods = { "indent" } }

      local folding = require "astroui.folding"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "content", "" })
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.require'astroui.folding'.foldexpr()"

      assert(vim.wo.foldexpr == "v:lua.require'astroui.folding'.foldexpr()")
      assert(folding.foldexpr(1) == 0)
    ]]
    end
  )
end

T["AUI-CHILD-FOLD-02 runs setup, user capability payloads, and buffer cleanup through Neovim autocmds"] = function()
  with_child(
    function(child)
      child.lua [[
      local astroui = require "astroui"
      astroui.config.folding = { enabled = true, methods = { "lsp" } }

      local folding = require "astroui.folding"
      local queries = 0
      local original_get_clients = vim.lsp.get_clients
      vim.lsp.get_clients = function()
        queries = queries + 1
        return {}
      end

      folding.setup()
      folding.setup()
      assert(vim.api.nvim_get_commands({}).AstroFoldInfo ~= nil)

      local buffer = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "child buffer" })
      vim.api.nvim_set_current_buf(buffer)
      vim.api.nvim_exec_autocmds("User", {
        pattern = "AstroLspCapability",
        data = { client_id = 1, bufnr = buffer },
      })
      vim.api.nvim_exec_autocmds("User", { pattern = "AstroLspCapability", data = {} })
      vim.api.nvim_buf_delete(buffer, { force = true })
      vim.lsp.get_clients = original_get_clients

      assert(queries == 1)
    ]]
    end
  )
end

return T
