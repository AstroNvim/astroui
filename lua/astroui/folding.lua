-- AstroNvim Folding Utilities
--
-- Helper functions for configuring folding in Neovim
--
-- This module can be loaded with `local astro = require "astroui.folding"`
--
-- copyright 2024
-- license GNU General Public License v3.0
local M = {}

local config = require("astroui").config.folding

local is_setup = false
local lsp_bufs = {}
local ts_bufs = {}

local fold_methods = {
  lsp = function(lnum, bufnr)
    if lsp_bufs[bufnr or vim.api.nvim_get_current_buf()] then return vim.lsp.foldexpr(lnum) end
  end,
  treesitter = function(lnum, bufnr)
    if ts_bufs[bufnr] == nil then
      if not require("astrocore").is_available "nvim-treesitter" or package.loaded["nvim-treesitter"] then
        ts_bufs[bufnr] = vim.bo.filetype and pcall(vim.treesitter.get_parser, bufnr)
      end
    end
    if ts_bufs[bufnr] then return vim.treesitter.foldexpr(lnum) end
  end,
  indent = function(lnum, bufnr)
    if not lnum then lnum = vim.v.lnum end
    if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
    return vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]:match "^%s*$" and "="
      or math.floor(vim.fn.indent(lnum) / vim.bo[bufnr].shiftwidth)
  end,
}

--- Check if folding is enabled for a buffer
---@param bufnr integer The buffer to check (defaults to current buffer)
---@return boolean enabled whether or not the buffer is enabled for folding
function M.is_enabled(bufnr)
  local enabled = config and config.enabled
  if type(enabled) == "function" then enabled = enabled(bufnr or vim.api.nvim_get_current_buf()) end
  return enabled == true
end

--- A fold expression for doing LSP and Treesitter based folding
---@param lnum? integer the current line number
---@return string foldlevel the calculated fold level
function M.foldexpr(lnum)
  if not is_setup then M.setup() end
  local bufnr = vim.api.nvim_get_current_buf()
  if M.is_enabled(bufnr) then
    for _, method in ipairs(config and config.methods or {}) do
      local fold_method = fold_methods[method]
      if fold_method then
        local fold = fold_method(lnum, bufnr)
        if fold then return fold end
      end
    end
  end
  -- fallback to no folds
  return "0"
end

--- Get the current folding status of a given buffer
---@param bufnr? integer the buffer to check the folding status for
function M.info(bufnr)
  if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
  local lines = {}
  local enabled = M.is_enabled(bufnr)
  table.insert(lines, "Buffer folding is **" .. (enabled and "Enabled" or "Disabled") .. "**\n")
  local methods = config and config.methods or {}
  for _, method in pairs(methods) do
    local fold_method = fold_methods[method]
    local available = "Unavailable"
    local surround = ""
    if not fold_method then
      available = "*Invalid*"
    elseif fold_method(1, bufnr) then
      available = "Available"
      if enabled then
        surround = "**"
        enabled = false
      end
    end
    table.insert(lines, ("%s`%s`: %s%s"):format(surround, method, available, surround))
  end
  table.insert(lines, "```lua")
  table.insert(lines, "methods = " .. vim.inspect(methods))
  table.insert(lines, "```")
  require("astrocore").notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "AstroNvim Folding" })
end

-- TODO: remove helper function when dropping support for Neovim v0.10

---@param client vim.lsp.Client
---@param method string
---@param bufnr? integer
local function supports_method(client, method, bufnr)
  if vim.fn.has "nvim-0.11" == 1 then
    return client:supports_method(method, bufnr)
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    return client.supports_method(method, { bufnr = bufnr })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("AstroFoldInfo", function() M.info() end, { desc = "Display folding information" })
  -- TODO: remove check when dropping support for Neovim v0.10
  if vim.lsp.foldexpr then
    local augroup = vim.api.nvim_create_augroup("astroui_foldexpr", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "Monitor attached LSP clients with fold providers",
      group = augroup,
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if supports_method(client, "textDocument/foldingRange", args.buf) then lsp_bufs[args.buf] = true end
      end,
    })
    vim.api.nvim_create_autocmd("LspDetach", {
      group = augroup,
      desc = "Safely remove LSP folding providers when language servers detach",
      callback = function(args)
        if not vim.api.nvim_buf_is_valid(args.buf) then return end
        for _, client in pairs(vim.lsp.get_clients { bufnr = args.buf }) do
          if client.id ~= args.data.client_id and supports_method(client, "textDocument/foldingRange", args.buf) then
            return
          end
        end
        lsp_bufs[args.buf] = nil
      end,
    })
  end
  is_setup = true
end

return M
