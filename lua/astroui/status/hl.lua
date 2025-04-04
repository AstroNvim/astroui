---AstroNvim Status Highlighting
---
---Statusline related highlighting utilities
---
---This module can be loaded with `local hl = require "astroui.status.hl"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui.status.hl
local M = {}

local config = assert(require("astroui").config.status)

--- Get the highlight background color of the lualine theme for the current colorscheme
---@param mode string the neovim mode to get the color of
---@param fallback string the color to fallback on if a lualine theme is not present
---@return string # The background color of the lualine theme or the fallback parameter if one doesn't exist
function M.lualine_mode(mode, fallback)
  if not vim.g.colors_name then return fallback end
  local lualine_avail, lualine = pcall(require, "lualine.themes." .. vim.g.colors_name)
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == "table" and lualine_opts.a.bg or fallback
end

--- Get the highlight for the current mode
---@return table # the highlight group for the current mode
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astroui.status").hl.mode },
function M.mode() return { bg = M.mode_bg() } end

--- Get the foreground color group for the current mode, good for usage with Heirline surround utility
---@return string # the highlight group for the current mode foreground
-- @usage local heirline_component = require("heirline.utils").surround({ "|", "|" }, require("astroui.status").hl.mode_bg, heirline_component),

function M.mode_bg() return config.modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
---@param self { bufnr: integer }? # component state that may hold the buffer number
---@return table # the highlight group for the current filetype foreground
-- @usage local heirline_component = { provider = require("astroui.status").provider.fileicon(), hl = require("astroui.status").hl.filetype_color },
function M.filetype_color(self)
  local _, color = require("astroui.status.utils").icon_provider(self and self.bufnr or 0)
  return { fg = color }
end

--- Merge the color and attributes from user settings for a given name
---@param name string, the name of the element to get the attributes and colors for
---@param include_bg? boolean whether or not to include background color (Default: false)
---@return table # a table of highlight information
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astroui.status").hl.get_attributes("treesitter") },
function M.get_attributes(name, include_bg)
  local hl = config.attributes[name] or {}
  local loaded_colors = require("heirline.highlights").get_loaded_colors()
  if loaded_colors[name .. "_fg"] then hl.fg = name .. "_fg" end
  if include_bg and loaded_colors[name .. "_bg"] then hl.bg = name .. "_bg" end
  return hl
end

--- Enable filetype color highlight if enabled in icon_highlights.file_icon options
---@param name string the icon_highlights.file_icon table element
---@return function # for setting hl property in a component
-- @usage local heirline_component = { provider = "Example Provider", hl = require("astroui.status").hl.file_icon("winbar") },
function M.file_icon(name)
  local hl_enabled = vim.tbl_get(config, "icon_highlights", "file_icon", name)
  return function(self)
    if hl_enabled == true or (type(hl_enabled) == "function" and hl_enabled(self)) then
      return M.filetype_color(self)
    end
  end
end

return M
