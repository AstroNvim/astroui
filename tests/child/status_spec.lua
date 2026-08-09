local MiniTest = require "mini.test"
local helpers = require "helpers"

local T = MiniTest.new_set()

T["AUI-CHILD-STATUS-01 starts an isolated child"] = function()
  local child = helpers.start_child()
  local ok, result = xpcall(function() assert.is_true(child:is_running()) end, debug.traceback)
  local stopped, stop_error = pcall(helpers.stop_child, child)
  if not ok then error(result, 0) end
  if not stopped then error(stop_error, 0) end
end

T["AUI-CHILD-STATUS-02 normalizes real named and anonymous signs"] = function()
  local child = helpers.start_child()
  local ok, result = xpcall(function()
    child.lua [[
      local buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "status signs" })
      vim.fn.sign_define("AUIChildNamedSign", { text = "N ", texthl = "Error", numhl = "WarningMsg" })
      vim.fn.sign_place(701, "AUIChildNamedGroup", "AUIChildNamedSign", buffer, { lnum = 1, priority = 90 })

      local anonymous = vim.api.nvim_create_namespace("")
      vim.api.nvim_buf_set_extmark(buffer, anonymous, 0, 0, {
        sign_text = "A ",
        sign_hl_group = "Question",
        priority = 30,
      })

      local normalized = require("astroui.status.utils").get_signs(buffer, 0)
      local result = {}
      for _, sign in ipairs(normalized) do
        if sign.sign_name == "AUIChildNamedSign" then
          result.named = {
            namespace = sign.namespace,
            anonymous = sign.anonymous,
            id = sign.id,
            rank = sign.rank,
            number_hl_group = sign.number_hl_group,
            order = sign.order,
          }
        elseif sign.sign_text == "A " then
          result.anonymous = {
            namespace = sign.namespace,
            anonymous = sign.anonymous,
            id = sign.id,
            rank = sign.rank,
            order = sign.order,
          }
        end
      end
      vim.g.aui_child_status_signs = result
    ]]

    local signs = child.lua_get "vim.g.aui_child_status_signs"
    assert.equals("AUIChildNamedGroup", signs.named.namespace)
    assert.is_false(signs.named.anonymous)
    assert.equals(701, signs.named.id)
    assert.equals(1, signs.named.rank)
    assert.equals("WarningMsg", signs.named.number_hl_group)
    assert.is_number(signs.named.order)

    assert.matches("^#%d+$", signs.anonymous.namespace)
    assert.is_true(signs.anonymous.anonymous)
    assert.equals(math.huge, signs.anonymous.rank)
    assert.is_number(signs.anonymous.order)
  end, debug.traceback)
  local stopped, stop_error = pcall(helpers.stop_child, child)
  if not ok then error(result, 0) end
  if not stopped then error(stop_error, 0) end
end

T["AUI-CHILD-STATUS-03 renders one sign in the merged number slot"] = function()
  local child = helpers.start_child()
  local ok, result = xpcall(function()
    child.lua [[
      local buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "signed number" })
      vim.wo.number = true
      vim.wo.signcolumn = "number"
      vim.fn.sign_define("AUIChildNumberSign", { text = "X ", numhl = "Error" })
      vim.fn.sign_place(702, "AUIChildNumberGroup", "AUIChildNumberSign", buffer, { lnum = 1, priority = 90 })

      local provider = require "astroui.status.provider"
      _G.aui_child_statuscolumn = function()
        return provider.numbercolumn()({ bufnr = buffer }) .. provider.signcolumn()
      end
      vim.o.statuscolumn = "%!v:lua.aui_child_statuscolumn()"
      vim.g.aui_child_statuscolumn_rendered = vim.api.nvim_eval_statusline(vim.o.statuscolumn, {
        winid = 0,
        use_statuscol_lnum = 1,
      }).str
    ]]

    local rendered = child.lua_get "vim.g.aui_child_statuscolumn_rendered"
    assert.equals(1, select(2, rendered:gsub("X", "")))
    assert.is_nil(rendered:find("1", 1, true))
  end, debug.traceback)
  local stopped, stop_error = pcall(helpers.stop_child, child)
  if not ok then error(result, 0) end
  if not stopped then error(stop_error, 0) end
end

return T
