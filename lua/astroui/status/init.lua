---AstroNvim Status Initializers
---
---Statusline related init functions for building dynamic statusline components
---
---This module can be loaded with `local init = require "astroui.status.init"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui.status.init
local M = {}

local astro = require "astrocore"
local ui = require "astroui"
local config = assert(ui.config.status)
local get_icon = ui.get_icon
local extend_tbl = astro.extend_tbl

local provider = require "astroui.status.provider"
local status_utils = require "astroui.status.utils"

--- An `init` function to build a set of children components for LSP breadcrumbs
---@param opts? AstroUIInitBreadcrumbsOpts component init options
---@return function # The Heirline init function
-- @usage local heirline_component = { init = require("astroui.status").init.breadcrumbs { padding = { left = 1 } } }
function M.breadcrumbs(opts)
  opts = extend_tbl({
    max_depth = 5,
    separator = config.separators.breadcrumbs or "  ",
    icon = { enabled = true, hl = config.icon_highlights.breadcrumbs },
    padding = { left = 0, right = 0 },
  }, opts)
  return function(self)
    local data = require("aerial").get_location(true) or {}
    local children = {}
    -- add prefix if needed, use the separator if true, or use the provided character
    if opts.prefix and not vim.tbl_isempty(data) then
      table.insert(children, { provider = opts.prefix == true and opts.separator or opts.prefix })
    end
    local start_idx = 0
    if opts.max_depth and opts.max_depth > 0 then
      start_idx = #data - opts.max_depth
      if start_idx > 0 then table.insert(children, { provider = get_icon "Ellipsis" .. opts.separator }) end
    end
    -- create a child for each level
    for i, d in ipairs(data) do
      if i > start_idx then
        local child = {
          { provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", "") }, -- add symbol name
          on_click = { -- add on click function
            minwid = status_utils.encode_pos(d.lnum, d.col, self.winnr),
            callback = function(_, minwid)
              local lnum, col, winnr = status_utils.decode_pos(minwid)
              vim.api.nvim_win_set_cursor(assert(vim.fn.win_getid(winnr)), { lnum, col })
            end,
            name = "heirline_breadcrumbs",
          },
        }
        if opts.icon.enabled then -- add icon and highlight if enabled
          local hl = opts.icon.hl
          if type(hl) == "function" then hl = hl(self) end
          local hlgroup = ("Aerial%sIcon"):format(d.kind)
          table.insert(child, 1, {
            provider = ("%s "):format(d.icon),
            hl = (hl and vim.fn.hlexists(hlgroup) == 1) and hlgroup or nil,
          })
        end
        if #data > 1 and i < #data then table.insert(child, { provider = opts.separator }) end -- add a separator only if needed
        table.insert(children, child)
      end
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = status_utils.pad_string(" ", { left = opts.padding.left - 1 }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = status_utils.pad_string(" ", { right = opts.padding.right - 1 }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

--- An `init` function to build a set of children components for a separated path to file
---@param opts? AstroUIInitSeparatedPathOpts component init options
---@return function # The Heirline init function
-- @usage local heirline_component = { init = require("astroui.status").init.separated_path { padding = { left = 1 } } }
function M.separated_path(opts)
  opts = extend_tbl({
    max_depth = 3,
    path_func = provider.unique_path(),
    delimiter = vim.fn.has "win32" == 1 and "\\" or "/",
    separator = config.separators.path or "  ",
    suffix = true,
    padding = { left = 0, right = 0 },
  }, opts)
  if opts.suffix == true then opts.suffix = opts.separator end
  return function(self)
    local path = opts.path_func(self)
    if path == "." then path = "" end -- if there is no path, just replace with empty string
    local data = vim.fn.split(path, opts.delimiter)
    local children = {}
    -- add prefix if needed, use the separator if true, or use the provided character
    if opts.prefix and not vim.tbl_isempty(data) then
      table.insert(children, { provider = opts.prefix == true and opts.separator or opts.prefix })
    end
    local start_idx = 0
    if opts.max_depth and opts.max_depth > 0 then
      start_idx = #data - opts.max_depth
      if start_idx > 0 then table.insert(children, { provider = get_icon "Ellipsis" .. opts.separator }) end
    end
    -- create a child for each level
    for i, d in ipairs(data) do
      if i > start_idx then
        local child = { { provider = d } }
        local separator = i < #data and opts.separator or opts.suffix
        if separator then table.insert(child, { provider = separator }) end
        table.insert(children, child)
      end
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = status_utils.pad_string(" ", { left = opts.padding.left - 1 }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = status_utils.pad_string(" ", { right = opts.padding.right - 1 }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

---@class AstroUIUpdateEvent: vim.api.keyset.create_autocmd
---@field [1] any

---@alias AstroUIUpdateEvents AstroUIUpdateEvent|AstroUIUpdateEvent[]

--- An `init` function to build multiple update events which is not supported yet by Heirline's update field
---@param opts AstroUIUpdateEvents an array like table of autocmd events as either just a string or a table with custom patterns and callbacks. TODO: UPDATE TYPE
---@return function # The Heirline init function
-- @usage local heirline_component = { init = require("astroui.status").init.update_events { "BufEnter", { "User", pattern = "LspProgressUpdate" } } }
function M.update_events(opts)
  if not vim.islist(opts) then opts = { opts } end
  ---@cast opts AstroUIUpdateEvent[]
  return function(self)
    if not rawget(self, "once") then
      local function clear_cache() self._win_cache = nil end
      for _, event in ipairs(opts) do
        local event_opts = { callback = clear_cache }
        if type(event) == "table" then
          event_opts.pattern = event.pattern
          if event.callback then
            local callback = event.callback
            event_opts.callback = function(args)
              clear_cache()
              callback(self, args)
            end
          end
          event = event[1]
        end
        vim.api.nvim_create_autocmd(event, event_opts)
      end
      self.once = true
    end
  end
end

return M
