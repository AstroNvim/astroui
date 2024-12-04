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

local fold_methods = {
  lsp = function(lnum, bufnr)
    if lsp_bufs[bufnr or vim.api.nvim_get_current_buf()] then return vim.lsp.foldexpr(lnum) end
  end,
  treesitter = function(lnum, bufnr)
    if vim.bo.filetype and vim.treesitter.get_parser(bufnr, nil, { error = false }) then
      return vim.treesitter.foldexpr(lnum)
    end
  end,
  indent = function(lnum, bufnr)
    if not lnum then lnum = vim.v.lnum end
    if not bufnr then bufnr = vim.api.nvim_get_current_buf() end
    return vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]:match "^%s*$" and "="
      or math.floor(vim.fn.indent(lnum) / vim.bo[bufnr].shiftwidth)
  end,
}

--- A fold expression for doing LSP and Treesitter based folding
---@param lnum? integer the current line number
---@return string the calculated fold level
function M.foldexpr(lnum)
  if not is_setup then M.setup() end
  local bufnr = vim.api.nvim_get_current_buf()
  -- check if folding is enabled
  local enabled = config and config.enabled
  if type(enabled) == "function" then enabled = enabled(bufnr) end
  if enabled then
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

function M.setup()
  -- TODO: remove check when dropping support for Neovim v0.10
  if vim.lsp.foldexpr then
    local augroup = vim.api.nvim_create_augroup("astroui_foldexpr", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "Monitor attached LSP clients with fold providers",
      group = augroup,
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client.supports_method "textDocument/foldingRange" then lsp_bufs[args.buf] = true end
      end,
    })
    vim.api.nvim_create_autocmd("LspDetach", {
      group = augroup,
      desc = "Safely remove LSP folding providers when language servers detach",
      callback = function(args)
        if not vim.api.nvim_buf_is_valid(args.buf) then return end
        for _, client in pairs(vim.lsp.get_clients { bufnr = args.buf }) do
          if client.id ~= args.data.client_id and client.supports_method "textDocument/foldingRange" then return end
        end
        lsp_bufs[args.buf] = nil
      end,
    })
  end
  is_setup = true
end

return M
