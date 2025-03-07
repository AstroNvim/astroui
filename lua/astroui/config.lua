-- AstroNvim UI Configuration
--
-- This module simply defines the configuration table structure for `opts` used in:
--
--    require("astroui").setup(opts)
--
-- copyright 2023
-- license GNU General Public License v3.0

---@alias StringMap table<string,string>
---@alias AstroUIIconHighlight (fun(self:table):boolean)|boolean
---@alias AstroUIHighlight vim.api.keyset.highlight
---@alias AstroUIHighlights table<string,vim.api.keyset.highlight>

---@class AstroUIFileIconHighlights
---@field tabline AstroUIIconHighlight? enable or disabling file icon highlighting in the tabline
---@field statusline AstroUIIconHighlight? enable or disable file icon highlighting in the statusline

---@class AstroUIIconHighlights
---@field breadcrumbs AstroUIIconHighlight? enable or disable breadcrumb icon highlighting
---Enable or disable the highlighting of filetype icons both in the statusline and tabline
---Example:
---
---```lua
---file_icon = {
---  tabline = function(self) return self.is_active or self.is_visible end,
---  statusline = true,
---}
---```
---@field file_icon AstroUIFileIconHighlights?

---@alias AstroUIFoldingMethod
---| "indent" # indentation based folding (`:h fold-indent`)
---| "lsp" # LSP based folding (`:h vim.lsp.foldexpr`)
---| "treesitter" # Treesitter based folding (`:h vim.treesitter.foldexpr`)

---@class AstroUIFoldingOpts
---@field enabled (boolean|fun(bufnr:integer):boolean)? whether folding should be enabled in a buffer or not
---@field methods AstroUIFoldingMethod[]? a table of folding methods in priority order

---@class AstroUILazygitOpts
---@field theme_path string? the path to the storage location for the lazygit theme configuration
---@field theme table<string|number,{fg:string?,bg:string?,bold:boolean?,reverse:boolean?,underline:boolean?,strikethrough:boolean?}>? table of highlight groups to use for the lazygit theme
---@field config table? arbitrary lazygit configuration structure

---@class AstroUIOpts
---Colorscheme set on startup, a string that is used with `:colorscheme astrodark`
---Example:
---
---```lua
---colorscheme = "astrodark"
---```
---@field colorscheme string?
---Configure how folding works
---Example:
---
---```lua
---folding = {
---  enabled = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
---  methods = { "lsp", "treesitter", "indent" },
---}
---```
---@field folding AstroUIFoldingOpts|false?
---Override highlights in any colorscheme
---Keys can be:
---  `init`: table of highlights to apply to all colorschemes
---  `<colorscheme_name>` override highlights in the colorscheme with name: `<colorscheme_name>`
---Example:
---
---```lua
---highlights = {
---     -- this table overrides highlights in all colorschemes
---     init = {
---       Normal = { bg = "#000000" },
---     },
---     -- a table of overrides/changes when applying astrotheme
---     astrotheme = {
---       Normal = { bg = "#000000" },
---     },
---}
---```
---@field highlights  table<string,(AstroUIHighlights|fun(colors_name: string):AstroUIHighlights)>?
---A table of icons in the UI using NERD fonts
---Example:
---
---```lua
---icons = {
---  GitAdd = "",
---}
---```
---@field icons StringMap?
--- A table of only text "icons" used when icons are disabled
---Example:
---
---```lua
---text_icons = {
---  GitAdd = "[+]",
---}
---```
---@field text_icons StringMap?
---Configuration options for the AstroNvim lines and bars built with the `status` API.
---Example:
---
---```lua
---status = {
---  attributes = {
---    git_branch = { bold = true },
---  },
---  colors = {
---    git_branch_fg = "#ABCDEF",
---  },
---  icon_highlights = {
---    breadcrumbs = false,
---    file_icon = {
---      tabline = function(self) return self.is_active or self.is_visible end,
---      statusline = true
---    }
---  },
---  separators = {
---    tab = { "", "" }
---  }
---}
---```
---@field status AstroUIStatusOpts?
---Configuration options for the Lazygit theme integration, set to false to disable
---Example:
---
---```lua
---lazygit = {
---  theme_path = vim.fs.normalize(vim.fn.stdpath "cache" .. "/lazygit-theme.yml"),
---  config = { os = { editPreset = "nvim-remote" } },
---  theme = {
---    [241] = { fg = "Special" },
---    activeBorderColor = { fg = "MatchParen", bold = true },
---    cherryPickedCommitBgColor = { fg = "Identifier" },
---    cherryPickedCommitFgColor = { fg = "Function" },
---    defaultFgColor = { fg = "Normal" },
---    inactiveBorderColor = { fg = "FloatBorder" },
---    optionsTextColor = { fg = "Function" },
---    searchingActiveBorderColor = { fg = "MatchParen", bold = true },
---    selectedLineBgColor = { bg = "Visual" },
---    unstagedChangesColor = { fg = "DiagnosticError" },
---  },
---}
---```
---@field lazygit AstroUILazygitOpts|false?

---@type AstroUIOpts
local M = {
  colorscheme = nil,
  folding = {},
  highlights = {},
  icons = {},
  text_icons = {},
  status = require "astroui.status.config",
  lazygit = false,
}

return M
