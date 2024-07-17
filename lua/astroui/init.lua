---AstroNvim UI Utilities
---
---UI utility functions to use within AstroNvim and user configurations.
---
---This module can be loaded with `local astro = require "astroui"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui
local M = {}

M.config = require "astroui.config"

--- Setup and configure AstroUI
---@param opts AstroUIOpts
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Load custom highlights from user configuration",
    group = vim.api.nvim_create_augroup("astronvim_highlights", { clear = true }),
    callback = function()
      if vim.g.colors_name then
        for _, module in ipairs { "init", vim.g.colors_name } do
          local highlights = M.config.highlights[module]
          if type(highlights) == "function" then highlights = highlights(vim.g.colors_name) end
          for group, spec in pairs(highlights or {}) do
            vim.api.nvim_set_hl(0, group, spec)
          end
        end
      end
      vim.api.nvim_exec_autocmds("User", { pattern = "AstroColorScheme", modeline = false })
    end,
  })

  local colorscheme = M.config.colorscheme
  if colorscheme and not pcall(vim.cmd.colorscheme, colorscheme) then
    vim.notify(("Error setting up colorscheme: `%s`"):format(colorscheme), vim.log.levels.ERROR, { title = "AstroUI" })
  end
end

--- Get highlight properties for a given highlight name
---@param name string The highlight group name
---@param fallback? table The fallback highlight properties
---@return table properties # the highlight group properties
function M.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if not vim.tbl_isempty(hl) then
      if not hl.fg then hl.fg = "NONE" end
      if not hl.bg then hl.bg = "NONE" end
      if hl.reverse then
        hl.fg, hl.bg, hl.reverse = hl.bg, hl.fg, nil
      end
      return hl
    end
  end
  return fallback or {}
end

--- Get an icon from the AstroNvim internal icons if it is available and return it
---@param kind string The kind of icon in astroui.icons to retrieve
---@param padding? integer Padding to add to the end of the icon
---@param no_fallback? boolean Whether or not to disable fallback to text icon
---@return string icon
function M.get_icon(kind, padding, no_fallback)
  local icons_enabled = vim.g.icons_enabled ~= false
  if not icons_enabled and no_fallback then return "" end
  local icon_pack = assert(M.config[icons_enabled and "icons" or "text_icons"])
  local icon = icon_pack[kind]
  return icon and icon .. (" "):rep(padding or 0) or ""
end

--- Get a icon spinner table if it is available in the AstroNvim icons. Icons in format `kind1`,`kind2`, `kind3`, ...
---@param kind string The kind of icon to check for sequential entries of
---@return string[]|nil spinners # A collected table of spinning icons in sequential order or nil if none exist
function M.get_spinner(kind, ...)
  local spinner = {}
  repeat
    local icon = M.get_icon(("%s%d"):format(kind, #spinner + 1), ...)
    if icon ~= "" then table.insert(spinner, icon) end
  until not icon or icon == ""
  if #spinner > 0 then return spinner end
end

return M
