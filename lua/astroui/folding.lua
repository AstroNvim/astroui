-- AstroNvim Folding Utilities
--
-- Helper functions for configuring folding in Neovim
--
-- This module can be loaded with `local astro = require "astroui.folding"`
--
-- copyright 2024
-- license GNU General Public License v3.0

local M = {}

local lsp_bufs = {}

--- A fold expression for doing LSP and Treesitter based folding
---@param lnum? integer the current line number
---@return string the calculated fold level
function M.foldexpr(lnum)
  local buf = vim.api.nvim_get_current_buf()
  if not require("astrocore.buffer").is_valid(buf) then return "0" end
  if lsp_bufs[buf] then return vim.lsp.foldexpr(lnum) end
  local filetype = vim.bo[buf].filetype
  if filetype == "" or filetype:find "dashboard" then return "0" end
  return vim.treesitter.get_parser(buf, nil, { error = false }) and vim.treesitter.foldexpr(lnum) or "0"
end

function M.setup()
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

return M
