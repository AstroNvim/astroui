-- AstroNvim Folding Utilities
--
-- Helper functions for configuring folding in Neovim
--
-- This module can be loaded with `local astro = require "astroui.folding"`
--
-- copyright 2024
-- license GNU General Public License v3.0

local M = {}

local is_setup = false
local lsp_bufs = {}

--- A fold expression for doing LSP and Treesitter based folding
---@param lnum? integer the current line number
---@return string the calculated fold level
function M.foldexpr(lnum)
  if not is_setup then M.setup() end
  local bufnr = vim.api.nvim_get_current_buf()
  -- only fold real file buffers
  if not require("astrocore.buffer").is_valid(bufnr) then return "0" end
  -- if an LSP with folding is attached us it for folding
  if lsp_bufs[bufnr] then return vim.lsp.foldexpr(lnum) end
  local filetype = vim.bo[bufnr].filetype
  -- don't fold dashboards
  if filetype:find "dashboard" then return "0" end
  -- if filetype and a treesitter parser exists, use treesitter for folding
  if filetype and vim.treesitter.get_parser(bufnr, nil, { error = false }) then return vim.treesitter.foldexpr(lnum) end
  -- fallback to indentation based folding
  if not lnum then lnum = vim.v.lnum end
  return vim.fn.getline(lnum):match "^%s*$" and "=" or math.floor(vim.fn.indent(lnum) / vim.bo[bufnr].shiftwidth)
end

function M.setup()
  -- TODO: remove check when dropping support for Neovim v0.10
  if vim.fn.has "nvim-0.11" == 1 then
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
