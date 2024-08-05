---AstroNvim Status Conditions
---
---Statusline related condition functions to use with Heirline
---
---This module can be loaded with `local condition = require "astroui.status.condition"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui.status.condition
local M = {}

---@alias BufMatcherPattern string
---@alias BufMatcherPatterns BufMatcherPattern|BufMatcherPattern[]
---@alias BufMatcherKinds "filetype"|"buftype"|"bufname"
---@alias BufMatcher fun(patterns: BufMatcherPatterns, bufnr: integer): boolean

---@param str BufMatcherPattern
---@param patterns BufMatcherPatterns
---@return boolean
local function pattern_match(str, patterns)
  if type(patterns) == "string" then patterns = { patterns } end
  for _, pattern in ipairs(patterns) do
    if str:find(pattern) then return true end
  end
  return false
end

---@type table<BufMatcherKinds, BufMatcher>
local buf_matchers = {
  filetype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr].filetype, pattern_list) end,
  buftype = function(pattern_list, bufnr) return pattern_match(vim.bo[bufnr].buftype, pattern_list) end,
  bufname = function(pattern_list, bufnr)
    local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    ---@cast bufname -nil
    return pattern_match(bufname, pattern_list)
  end,
}

--- A condition function if the buffer filetype,buftype,bufname match a pattern
---@param patterns table<BufMatcherKinds, BufMatcherPatterns> the table of patterns to match
---@param bufnr integer? of the buffer to match (Default: 0 [current])
---@param op "and"|"or"? whether or not to require all pattern types to match or any (Default: "or")
---@return boolean # whether or not the buffer filetype,buftype,bufname match a pattern
-- @usage local heirline_component = { provider = "Example Provider", condition = function() return require("astroui.status").condition.buffer_matches { buftype = { "terminal" } } end }
function M.buffer_matches(patterns, bufnr, op)
  if not op then op = "or" end
  if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
  if vim.api.nvim_buf_is_valid(bufnr) then
    for kind, pattern_list in pairs(patterns) do
      if buf_matchers[kind](pattern_list, bufnr) then
        if op == "or" then return true end
      else
        if op == "and" then return false end
      end
    end
  end
  return op == "and"
end

--- A condition function if the window is currently active
---@return boolean # whether or not the window is currently actie
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_active }
function M.is_active() return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) end

--- A condition function if a macro is being recorded
---@return boolean # whether or not a macro is currently being recorded
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_macro_recording }
function M.is_macro_recording() return vim.fn.reg_recording() ~= "" end

--- A condition function if search is visible
---@return boolean # whether or not searching is currently visible
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_hlsearch }
function M.is_hlsearch() return vim.v.hlsearch ~= 0 end

--- A condition function if showcmdloc is set to statusline
---@return boolean # whether or not statusline showcmd is enabled
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_statusline_showcmd }
function M.is_statusline_showcmd() return vim.fn.has "nvim-0.9" == 1 and vim.opt.showcmdloc:get() == "statusline" end

--- A condition function if the current file is in a git repo
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not the current file is in a git repo
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_git_repo }
function M.is_git_repo(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  return vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_status_dict
end

--- A condition function if there are any git changes
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not there are any git changes
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.git_changed }
function M.git_changed(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  local git_status = vim.b[bufnr].gitsigns_status_dict
  return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

--- A condition function if the current buffer is modified
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not the current buffer is modified
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.file_modified }
function M.file_modified(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  return vim.bo[bufnr].modified
end

--- A condition function if the current buffer is read only
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not the current buffer is read only or not modifiable
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.file_read_only }
function M.file_read_only(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  local buffer = vim.bo[bufnr]
  return not buffer.modifiable or buffer.readonly
end

--- A condition function if the current file has any diagnostics
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not the current file has any diagnostics
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.has_diagnostics }
function M.has_diagnostics(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  if package.loaded["astrocore"] and require("astrocore").config.features.diagnostics_mode == 0 then return false end
  -- TODO: remove when dropping support for neovim 0.9
  if vim.diagnostic.count then
    return vim.tbl_contains(vim.diagnostic.count(bufnr), function(v) return v > 0 end, { predicate = true })
  else
    return #vim.diagnostic.get(bufnr) > 0
  end
end

--- A condition function if there is a defined filetype
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not there is a filetype
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.has_filetype }
function M.has_filetype(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  local filetype = vim.bo[bufnr].filetype
  return filetype and filetype ~= ""
end

--- A condition function if a buffer is a file
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not the buffer is a file
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_file }
function M.is_file(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  return vim.bo[bufnr].buftype == ""
end

--- A condition function if a virtual environment is activated
---@return boolean # whether or not virtual environment is activated
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.has_virtual_env }
function M.has_virtual_env() return vim.env.VIRTUAL_ENV ~= nil or vim.env.CONDA_DEFAULT_ENV ~= nil end

--- A condition function if Aerial is available
---@return boolean # whether or not aerial plugin is installed
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.aerial_available }
-- function M.aerial_available() return is_available "aerial.nvim" end
function M.aerial_available() return package.loaded["aerial"] end

--- A condition function if LSP is attached
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not LSP is attached
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.lsp_attached }
function M.lsp_attached(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = 0 end
  return (
        -- HACK: Check for lsp utilities loaded first, get_active_clients seems to have a bug if called too early (tokyonight colorscheme seems to be a good way to expose this for some reason)
package.loaded["astrolsp"]
    -- TODO: remove get_active_clients when dropping support for Neovim 0.9
    ---@diagnostic disable-next-line: deprecated
    and next((vim.lsp.get_clients or vim.lsp.get_active_clients) { bufnr = bufnr }) ~= nil
  )
    or (package.loaded["conform"] and next(require("conform").list_formatters(bufnr)) ~= nil)
    or (package.loaded["lint"] and next(require("lint")._resolve_linter_by_ft(vim.bo[bufnr].filetype or "")) ~= nil)
end

--- A condition function if a treesitter parser for a given buffer is available
---@param bufnr table|integer a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
---@return boolean # whether or not treesitter is active
-- @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.treesitter_available }
function M.treesitter_available(bufnr)
  if type(bufnr) == "table" then bufnr = bufnr.bufnr end
  if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
  return vim.treesitter.highlighter.active[bufnr] ~= nil
end

--- A condition function if the foldcolumn is enabled
---@return boolean # true if vim.opt.foldcolumn > 0, false if vim.opt.foldcolumn == 0
function M.foldcolumn_enabled() return vim.opt.foldcolumn:get() ~= "0" end

--- A condition function if the number column is enabled
---@return boolean # true if vim.opt.number or vim.opt.relativenumber, false if neither
function M.numbercolumn_enabled() return vim.opt.number:get() or vim.opt.relativenumber:get() end

--- A condition function if the signcolumn is enabled
---@return boolean # false if vim.opt.signcolumn == "no", true otherwise
function M.signcolumn_enabled() return vim.opt.signcolumn:get() ~= "no" end

return M
