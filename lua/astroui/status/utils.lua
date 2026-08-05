---AstroNvim Status Utilities
---
---Statusline related uitility functions
---
---This module can be loaded with `local status_utils = require "astroui.status.utils"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui.status.utils
local M = {}

local astro = require "astrocore"
local ui = require "astroui"
local config = assert(ui.config.status)
local extend_tbl = astro.extend_tbl

--- Convert a component parameter table to a table that can be used with the component builder
---@param opts? table a table of provider options
---@param provider? function|string a provider in `M.providers`
---@return table|false # the provider table that can be used in `M.component.builder`
function M.build_provider(opts, provider, _)
  return opts
      and {
        provider = provider,
        opts = opts,
        condition = opts.condition,
        on_click = opts.on_click,
        update = opts.update,
        hl = opts.hl,
      }
    or false
end

--- Convert key/value table of options to an array of providers for the component builder
---@param opts table the table of options for the components
---@param providers string[] an ordered list like array of providers that are configured in the options table
---@param setup? function a function that takes provider options table, provider name, provider index and returns the setup provider table, optional, default is `M.build_provider`
---@return table # the fully setup options table with the appropriately ordered providers
function M.setup_providers(opts, providers, setup)
  setup = setup or M.build_provider
  for i, provider in ipairs(providers) do
    opts[i] = setup(opts[provider], provider, i)
  end
  return opts
end

--- A utility function to get the width of the bar
---@param is_winbar? boolean true if you want the width of the winbar, false if you want the statusline width
---@return integer # the width of the specified bar
function M.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

--- Add left and/or right padding to a string
---@param str string the string to add padding to
---@param padding AstroUIStatusPadding a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string
---@return string # the padded string
function M.pad_string(str, padding)
  padding = padding or {}
  return str and str ~= "" and (" "):rep(padding.left or 0) .. str .. (" "):rep(padding.right or 0) or ""
end

---@param str string the string to escape
local function escape(str) return str:gsub("%%", "%%%%") end

--- A utility function to stylize a string with an icon from lspkind, separators, and left/right padding
---@param str? string the string to stylize
---@param opts? AstroUIStatusStylizeOpts options for stylizing the string
---@return string # the stylized string
-- @usage local string = require("astroui.status").utils.stylize("Hello", { padding = { left = 1, right = 1 }, icon = { kind = "String" } })
function M.stylize(str, opts)
  opts = extend_tbl({
    padding = { left = 0, right = 0 },
    separator = { left = "", right = "" },
    show_empty = false,
    escape = true,
    icon = { kind = "NONE", padding = { left = 0, right = 0 } },
  }, opts)
  local icon = M.pad_string(ui.get_icon(opts.icon.kind), opts.icon.padding)
  return str
      and (str ~= "" or opts.show_empty)
      and opts.separator.left .. M.pad_string(icon .. (opts.escape and escape(str) or str), opts.padding) .. opts.separator.right
    or ""
end

--- Surround component with separator and color adjustment
---@param separator string|string[] the separator index to use in the `separators` table
---@param color function|string|table the color to use as the separator foreground/component background
---@param component table the component to surround
---@param condition boolean|function the condition for displaying the surrounded component
---@param update? AstroUIUpdateEvents control updating of separators, either a list of events or true to update freely
---@return table # the new surrounded component
function M.surround(separator, color, component, condition, update)
  local function surround_color(self)
    local colors = type(color) == "function" and color(self) or color
    return type(colors) == "string" and { main = colors } or colors
  end

  separator = type(separator) == "string" and config.separators[separator] or separator
  local surrounded = { condition = condition }
  local base_separator = {
    update = (update or type(color) ~= "function") and function() return false end,
    init = update and require("astroui.status.init").update_events(update),
  }
  if separator[1] ~= "" then
    table.insert(
      surrounded,
      extend_tbl {
        provider = separator[1], --bind alt-j:down,alt-k:up
        hl = function(self)
          local s_color = surround_color(self)
          if s_color then return { fg = s_color.main, bg = s_color.left } end
        end,
      }
    )
  end
  local component_hl = component.hl
  component.hl = function(self)
    local hl = {}
    if component_hl then hl = type(component_hl) == "table" and vim.deepcopy(component_hl) or component_hl(self) end
    local s_color = surround_color(self)
    if s_color then hl.bg = s_color.main end
    return hl
  end
  table.insert(surrounded, component)
  if separator[2] ~= "" then
    table.insert(
      surrounded,
      extend_tbl(base_separator, {
        provider = separator[2],
        hl = function(self)
          local s_color = surround_color(self)
          if s_color then return { fg = s_color.main, bg = s_color.right } end
        end,
      })
    )
  end
  return surrounded
end

---@type false|nil|fun(bufname: string, filetype: string, buftype: string): string?,string?
local cached_icon_provider
--- Resolve the icon and color information for a given buffer
---@param bufnr integer the buffer number to resolve the icon and color of
---@return string? icon the icon string
---@return string? color the hex color of the icon
function M.icon_provider(bufnr)
  if not bufnr then bufnr = 0 end
  local bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype
  if cached_icon_provider then return cached_icon_provider(bufname, filetype, buftype) end
  if cached_icon_provider == false then
    if not _G.MiniIcons and not package.loaded["nvim-web-devicons"] then return end
    cached_icon_provider = nil
  end

  local _, mini_icons = pcall(require, "mini.icons")
  -- mini.icons
  if _G.MiniIcons then
    cached_icon_provider = function(_bufname, _filetype)
      local icon, hl, is_default = mini_icons.get("file", _bufname)
      if is_default then
        icon, hl, is_default = mini_icons.get("filetype", _filetype)
      end
      local color = require("astroui").get_hlgroup(hl).fg
      if type(color) == "number" then color = string.format("#%06x", color) end
      ---@cast color string?
      return icon, color
    end
    return cached_icon_provider(bufname, filetype, bufname)
  end

  -- nvim-web-devicons
  local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
  if devicons_avail then
    cached_icon_provider = function(_bufname, _filetype, _buftype)
      local icon, color = devicons.get_icon_color(_bufname)
      if not color then
        icon, color = devicons.get_icon_color_by_filetype(_filetype, { default = _buftype == "" })
      end
      return icon, color
    end
    return cached_icon_provider(bufname, filetype, buftype)
  end

  -- fallback to no icon provider
  cached_icon_provider = false
end

--- Encode a position to a single value that can be decoded later
---@param line integer line number of position
---@param col integer column number of position
---@param winnr integer a window number
---@return integer the encoded position
function M.encode_pos(line, col, winnr)
  local function validate(value, maximum, name)
    if type(value) ~= "number" or value % 1 ~= 0 or value < 0 or value > maximum then
      error(("%s must be an integer between 0 and %d"):format(name, maximum), 3)
    end
  end
  validate(line, 65535, "line")
  validate(col, 1023, "col")
  validate(winnr, 63, "winnr")
  return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
end

--- Decode a previously encoded position to it's sub parts
---@param c integer the encoded position
---@return integer line, integer column, integer window
function M.decode_pos(c) return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63) end

---@private
function M.sign_is_higher(current, sign)
  if not current then return true end
  local current_priority, priority = current.priority or 0, sign.priority or 0
  if priority ~= current_priority then return priority > current_priority end
  local current_id, id = current.id or 0, sign.id or 0
  if id ~= current_id then return id > current_id end
  local current_rank, rank = current.rank or math.huge, sign.rank or math.huge
  local current_ranked, ranked = current_rank ~= math.huge, rank ~= math.huge
  if ranked ~= current_ranked then return ranked end
  if ranked and rank ~= current_rank then return rank < current_rank end
  return (sign.order or 0) > (current.order or 0)
end

---@class AstroUIStatusSign: vim.api.keyset.extmark_details
---@field anonymous boolean
---@field id integer
---@field namespace string
---@field order integer
---@field rank number

function M.get_signs(bufnr, row)
  local namespaces = {}
  for namespace, ns_id in pairs(vim.api.nvim_get_namespaces()) do
    namespaces[ns_id] = namespace
  end

  local placements = {}
  local placed = vim.fn.sign_getplaced(bufnr, { group = "*", lnum = row + 1 })[1]
  for rank, sign in ipairs(placed and placed.signs or {}) do
    local key = sign.group .. "\0" .. sign.id
    if not placements[key] then placements[key] = {} end
    table.insert(placements[key], rank)
  end

  local placement_indices, signs = {}, {}
  for order, extmark in
    ipairs(
      vim.api.nvim_buf_get_extmarks(
        bufnr,
        -1,
        { row, 0 },
        { row, -1 },
        { details = true, type = "sign", overlap = true }
      )
    )
  do
    local details = extmark[4] --[[@as AstroUIStatusSign]]
    local namespace_name = details.ns_id and namespaces[details.ns_id]
    local namespace = namespace_name or (details.ns_id and ("#" .. details.ns_id)) or ""
    local placement_key = namespace_name and (namespace_name .. "\0" .. extmark[1])
      or not details.ns_id and ("\0" .. extmark[1])
    if placement_key then placement_indices[placement_key] = (placement_indices[placement_key] or 0) + 1 end
    local ranks = placement_key and placements[placement_key]
    details.anonymous = details.ns_id ~= nil and namespace_name == nil
    details.id = extmark[1]
    details.namespace = namespace
    details.order = order
    details.rank = ranks and ranks[placement_indices[placement_key]] or math.huge
    table.insert(signs, details)
  end
  return signs
end

--- Get a list of registered null-ls providers for a given filetype
---@param params table parameters to use for null-ls providers
---@return table # a table of null-ls sources
function M.null_ls_providers(params)
  local registered = {}
  -- try to load null-ls
  local sources_avail, sources = pcall(require, "null-ls.sources")
  if sources_avail then
    -- get the available sources of a given filetype
    for _, source in ipairs(sources.get_available(params.filetype)) do
      -- get each source name
      local runtime_condition = vim.tbl_get(source, "generator", "opts", "runtime_condition")
      for method in pairs(source.methods) do
        local source_activated = true
        if runtime_condition then -- try to calculate runtime_condition with supported parameters
          params.source_id = vim.tbl_get(source, "generator", "source_id")
          local condition_calculated, condition = pcall(runtime_condition, params)
          if condition_calculated then source_activated = condition end
        end
        if source_activated then
          registered[method] = registered[method] or {}
          table.insert(registered[method], source.name)
        end
      end
    end
  end
  -- return the found null-ls sources
  return registered
end

--- Get the null-ls sources for a given null-ls method
---@param params table parameters to use for checking null-ls sources
---@return string[] # the available sources for the given filetype and method
function M.null_ls_sources(params)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and M.null_ls_providers(params)[methods.internal[params.method]] or {}
end

--- A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any
---@param self any the self parameter from Heirline component on_click.callback function call
---@param minwid any the minwid parameter from Heirline component on_click.callback function call
---@param clicks any the clicks parameter from Heirline component on_click.callback function call
---@param button any the button parameter from Heirline component on_click.callback function call
---@param mods any the button parameter from Heirline component on_click.callback function call
---@return table # the argument table with the decoded mouse information and signcolumn signs information
-- @usage local heirline_component = { on_click = { callback = function(...) local args = require("astroui.status").utils.statuscolumn_clickargs(...) end } }
function M.statuscolumn_clickargs(self, minwid, clicks, button, mods)
  local args = {
    minwid = minwid,
    clicks = clicks,
    button = button,
    mods = mods,
    mousepos = vim.fn.getmousepos(),
  }
  args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
  if args.char == " " then args.char = vim.fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1) end

  self.bufnr = vim.api.nvim_win_get_buf(args.mousepos.winid)
  self.signs = {}
  local ambiguous = {}
  local rendered_signs = {}
  local function set_sign(key, sign)
    local conflict = ambiguous[key]
    if conflict then
      if sign.priority > conflict.priority or (sign.priority == conflict.priority and sign.id > conflict.id) then
        ambiguous[key], self.signs[key] = nil, sign
      end
      return
    end
    local current = self.signs[key]
    if
      current
      and (current.anonymous or sign.anonymous)
      and current.priority == sign.priority
      and current.id == sign.id
      and (current.ns_id ~= sign.ns_id or current.anonymous ~= sign.anonymous)
    then
      self.signs[key], ambiguous[key] = nil, { priority = sign.priority, id = sign.id }
    elseif M.sign_is_higher(current, sign) then
      self.signs[key] = sign
    end
  end
  local function insert_rendered_sign(sign)
    for index, current in ipairs(rendered_signs) do
      if M.sign_is_higher(current, sign) then
        table.insert(rendered_signs, index, sign)
        return
      end
    end
    table.insert(rendered_signs, sign)
  end
  local row = args.mousepos.line - 1
  for _, sign in ipairs(M.get_signs(self.bufnr, row)) do
    if sign.sign_text then
      local text = sign.sign_text:gsub("%s", "")
      local sign_info = {
        name = sign.sign_name,
        anonymous = sign.anonymous,
        text = sign.sign_text,
        texthl = sign.sign_hl_group or "NoTexthl",
        namespace = sign.namespace,
        priority = sign.priority or 0,
        id = sign.id,
        ns_id = sign.ns_id,
        order = sign.order,
        rank = sign.rank,
        matches = {},
      }
      set_sign(text, sign_info)
      sign_info.matches[text] = true
      for index = 0, vim.fn.strchars(text) - 1 do
        local char = vim.fn.strcharpart(text, index, 1)
        set_sign(char, sign_info)
        sign_info.matches[char] = true
      end
      insert_rendered_sign(sign_info)
    end
  end
  local signcolumn = vim.wo[args.mousepos.winid].signcolumn
  local sign_slots
  if signcolumn == "yes" or signcolumn == "number" then
    sign_slots = 1
  elseif signcolumn:find "^yes:" then
    sign_slots = tonumber(signcolumn:match "%d+")
  elseif signcolumn == "auto" then
    sign_slots = #rendered_signs > 0 and 1 or 0
  else
    local minimum, maximum = signcolumn:match "^auto:(%d+)%-(%d+)$"
    if minimum then
      local min = assert(tonumber(minimum))
      local max = assert(tonumber(maximum))
      sign_slots = math.max(min, math.min(#rendered_signs, max))
    else
      maximum = tonumber(signcolumn:match "^auto:(%d+)$")
      sign_slots = maximum and math.min(#rendered_signs, maximum) or 0
    end
  end
  local wininfo = vim.fn.getwininfo(args.mousepos.winid)[1]
  local signcolumn_start = wininfo and wininfo.textoff - sign_slots * 2 + 1
  local slot = signcolumn_start
    and args.mousepos.wincol
    and args.mousepos.wincol >= signcolumn_start
    and args.mousepos.wincol < signcolumn_start + sign_slots * 2
    and math.ceil((args.mousepos.wincol - signcolumn_start + 1) / 2)
  local slot_sign = slot and rendered_signs[slot]
  if slot_sign and slot_sign.matches[args.char] then
    local slot_ambiguous = false
    for _, sign in ipairs(rendered_signs) do
      if
        sign ~= slot_sign
        and sign.matches[args.char]
        and (sign.anonymous or slot_sign.anonymous)
        and sign.priority == slot_sign.priority
        and sign.id == slot_sign.id
        and (sign.ns_id ~= slot_sign.ns_id or sign.anonymous ~= slot_sign.anonymous)
      then
        slot_ambiguous = true
        break
      end
    end
    args.sign = not slot_ambiguous and slot_sign or nil
  else
    args.sign = self.signs[args.char]
  end
  vim.api.nvim_set_current_win(args.mousepos.winid)
  vim.api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })
  return args
end

return M
