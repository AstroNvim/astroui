---AstroNvim Status Providers
---
---Statusline related provider functions for building statusline components
---
---This module can be loaded with `local provider = require "astroui.status.provider"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui.status.provider
local M = {}

local astro = require "astrocore"
local extend_tbl = astro.extend_tbl
local is_available = astro.is_available
local luv = vim.uv or vim.loop -- TODO: REMOVE WHEN DROPPING SUPPORT FOR Neovim v0.9

local ui = require "astroui"
local config = assert(ui.config.status)
local get_icon = ui.get_icon
local condition = require "astroui.status.condition"
local status_utils = require "astroui.status.utils"

--- A provider function for the fill string
---@return string # the statusline string for filling the empty space
-- @usage local heirline_component = { provider = require("astroui.status").provider.fill }
function M.fill() return "%=" end

--- A provider function for the signcolumn string
---@param opts? table options passed to the stylize function
---@return string # the statuscolumn string for adding the signcolumn
-- @usage local heirline_component = { provider = require("astroui.status").provider.signcolumn }
-- @see astroui.status.utils.stylize
function M.signcolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  return status_utils.stylize("%s", opts)
end

-- local function to resolve the first sign in the signcolumn
-- specifically for usage when `signcolumn=number`
local function resolve_sign(bufnr, lnum)
  --- TODO: remove when dropping support for Neovim v0.9
  if vim.fn.has "nvim-0.10" == 0 then
    for _, sign in ipairs(vim.fn.sign_getplaced(bufnr, { group = "*", lnum = lnum })[1].signs) do
      local defined = vim.fn.sign_getdefined(sign.name)[1]
      if defined then return defined end
    end
  end

  local row = lnum - 1
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { row, 0 }, { row, -1 }, { details = true, type = "sign" })
  local ret
  for _, extmark in pairs(extmarks) do
    local sign_def = extmark[4]
    if sign_def.sign_text and (not ret or (ret.priority < sign_def.priority)) then ret = sign_def end
  end
  if ret then return { text = ret.sign_text, texthl = ret.sign_hl_group } end
end

--- A provider function for the numbercolumn string
---@param opts? table options passed to the stylize function
---@return function # the statuscolumn string for adding the numbercolumn
-- @usage local heirline_component = { provider = require("astroui.status").provider.numbercolumn }
-- @see astroui.status.utils.stylize
function M.numbercolumn(opts)
  opts = extend_tbl({ thousands = false, culright = true, escape = false }, opts)
  return function(self)
    local lnum, rnum, virtnum = vim.v.lnum, vim.v.relnum, vim.v.virtnum
    local num, relnum = vim.opt.number:get(), vim.opt.relativenumber:get()
    local bufnr = self and self.bufnr or 0
    local sign = vim.opt.signcolumn:get():find "nu" and resolve_sign(bufnr, lnum)
    local str
    if virtnum ~= 0 then
      str = "%="
    elseif sign then
      str = sign.text
      if sign.texthl then str = "%#" .. sign.texthl .. "#" .. str .. "%*" end
      str = "%=" .. str
    elseif not num and not relnum then
      str = "%="
    else
      local cur = relnum and (rnum > 0 and rnum or (num and lnum or 0)) or lnum
      if opts.thousands and cur > 999 then
        cur = cur:reverse():gsub("%d%d%d", "%1" .. opts.thousands):reverse():gsub("^%" .. opts.thousands, "")
      end
      str = (rnum == 0 and not opts.culright and relnum) and cur .. "%=" or "%=" .. cur
    end
    return status_utils.stylize(str, opts)
  end
end

--- A provider function for building a foldcolumn
---@param opts? table options passed to the stylize function
---@return function # a custom foldcolumn function for the statuscolumn that doesn't show the nest levels
-- @usage local heirline_component = { provider = require("astroui.status").provider.foldcolumn }
-- @see astroui.status.utils.stylize
function M.foldcolumn(opts)
  opts = extend_tbl({ escape = false }, opts)
  local ffi = require "astroui.ffi" -- get AstroUI C extensions
  local fillchars = vim.opt.fillchars:get()
  local foldopen = fillchars.foldopen or get_icon "FoldOpened"
  local foldclosed = fillchars.foldclose or get_icon "FoldClosed"
  local foldsep = fillchars.foldsep or get_icon "FoldSeparator"
  return function() -- move to M.fold_indicator
    local wp = ffi.C.find_window_by_handle(0, ffi.new "Error") -- get window handler
    local width = ffi.C.compute_foldcolumn(wp, 0) -- get foldcolumn width
    -- get fold info of current line
    local foldinfo = width > 0 and ffi.C.fold_info(wp, vim.v.lnum) or { start = 0, level = 0, llevel = 0, lines = 0 }

    local str = ""
    if width ~= 0 then
      str = vim.v.relnum > 0 and "%#FoldColumn#" or "%#CursorLineFold#"
      if foldinfo.level == 0 then
        str = str .. (" "):rep(width)
      else
        local closed = foldinfo.lines > 0
        local first_level = foldinfo.level - width - (closed and 1 or 0) + 1
        if first_level < 1 then first_level = 1 end

        for col = 1, width do
          str = str
            .. (
              (vim.v.virtnum ~= 0 and foldsep)
              or ((closed and (col == foldinfo.level or col == width)) and foldclosed)
              or ((foldinfo.start == vim.v.lnum and first_level + col > foldinfo.llevel) and foldopen)
              or foldsep
            )
          if col == foldinfo.level then
            str = str .. (" "):rep(width - col)
            break
          end
        end
      end
    end
    return status_utils.stylize(str .. "%*", opts)
  end
end

--- A provider function for the current tab numbre
---@return function # the statusline function to return a string for a tab number
-- @usage local heirline_component = { provider = require("astroui.status").provider.tabnr() }
function M.tabnr()
  return function(self) return (self and self.tabnr) and "%" .. self.tabnr .. "T " .. self.tabnr .. " %T" or "" end
end

--- A provider function for showing if spellcheck is on
---@param opts? table options passed to the stylize function
---@return function # the function for outputting if spell is enabled
-- @usage local heirline_component = { provider = require("astroui.status").provider.spell() }
-- @see astroui.status.utils.stylize
function M.spell(opts)
  opts = extend_tbl({ str = "", icon = { kind = "Spellcheck" }, show_empty = true }, opts)
  return function() return status_utils.stylize(vim.wo.spell and opts.str or nil, opts) end
end

--- A provider function for showing if paste is enabled
---@param opts? table options passed to the stylize function
---@return function # the function for outputting if paste is enabled
-- @usage local heirline_component = { provider = require("astroui.status").provider.paste() }
-- @see astroui.status.utils.stylize
function M.paste(opts)
  opts = extend_tbl({ str = "", icon = { kind = "Paste" }, show_empty = true }, opts)
  local paste = vim.opt.paste
  if type(paste) ~= "boolean" then paste = paste:get() end
  return function() return status_utils.stylize(paste and opts.str or nil, opts) end
end

--- A provider function for displaying if a macro is currently being recorded
---@param opts? table a prefix before the recording register and options passed to the stylize function
---@return function # a function that returns a string of the current recording status
-- @usage local heirline_component = { provider = require("astroui.status").provider.macro_recording() }
-- @see astroui.status.utils.stylize
function M.macro_recording(opts)
  opts = extend_tbl({ prefix = "@" }, opts)
  return function()
    local register = vim.fn.reg_recording()
    if register ~= "" then register = opts.prefix .. register end
    return status_utils.stylize(register, opts)
  end
end

--- A provider function for displaying the current command
---@param opts? table of options passed to the stylize function
---@return string # the statusline string for showing the current command
-- @usage local heirline_component = { provider = require("astroui.status").provider.showcmd() }
-- @see astroui.status.utils.stylize
function M.showcmd(opts)
  opts = extend_tbl({ minwid = 0, maxwid = 5, escape = false }, opts)
  return status_utils.stylize(("%%%d.%d(%%S%%)"):format(opts.minwid, opts.maxwid), opts)
end

--- A provider function for displaying the current search count
---@param opts? table options for `vim.fn.searchcount` and options passed to the stylize function
---@return function # a function that returns a string of the current search location
-- @usage local heirline_component = { provider = require("astroui.status").provider.search_count() }
-- @see astroui.status.utils.stylize
function M.search_count(opts)
  local search_func = vim.tbl_isempty(opts or {}) and function() return vim.fn.searchcount() end
    or function() return vim.fn.searchcount(opts) end
  return function()
    local search_ok, search = pcall(search_func)
    if search_ok and type(search) == "table" and search.total then
      return status_utils.stylize(
        ("%s%d/%s%d"):format(
          search.current > search.maxcount and ">" or "",
          math.min(search.current, search.maxcount),
          search.incomplete == 2 and ">" or "",
          math.min(search.total, search.maxcount)
        ),
        opts
      )
    end
  end
end

--- A provider function for showing the text of the current vim mode
---@param opts? table options for padding the text and options passed to the stylize function
---@return function # the function for displaying the text of the current vim mode
-- @usage local heirline_component = { provider = require("astroui.status").provider.mode_text() }
-- @see astroui.status.utils.stylize
function M.mode_text(opts)
  local max_length = math.max(unpack(vim.tbl_map(function(str) return #str[1] end, vim.tbl_values(config.modes))))
  return function()
    local text = config.modes[vim.fn.mode()][1]
    if opts and opts.pad_text then
      local padding = max_length - #text
      if opts.pad_text == "right" then
        text = (" "):rep(padding) .. text
      elseif opts.pad_text == "left" then
        text = text .. (" "):rep(padding)
      elseif opts.pad_text == "center" then
        local half_pad = padding / 2
        text = (" "):rep(math.floor(half_pad)) .. text .. (" "):rep(math.ceil(half_pad))
      end
    end
    return status_utils.stylize(text, opts)
  end
end

--- A provider function for showing the percentage of the current location in a document
---@param opts? table options for Top/Bot text, fixed width, and options passed to the stylize function
---@return function # the statusline string for displaying the percentage of current document location
-- @usage local heirline_component = { provider = require("astroui.status").provider.percentage() }
-- @see astroui.status.utils.stylize
function M.percentage(opts)
  opts = extend_tbl({ escape = false, fixed_width = true, edge_text = true }, opts)
  return function()
    local text = "%" .. (opts.fixed_width and (opts.edge_text and "2" or "3") or "") .. "p%%"
    if opts.edge_text then
      local current_line = vim.fn.line "."
      if current_line == 1 then
        text = "Top"
      elseif current_line == vim.fn.line "$" then
        text = "Bot"
      end
    end
    return status_utils.stylize(text, opts)
  end
end

--- A provider function for showing the current line and character in a document
---@param opts? table options for padding the line and character locations and options passed to the stylize function
---@return function # the statusline string for showing location in document line_num:char_num
-- @usage local heirline_component = { provider = require("astroui.status").provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
-- @see astroui.status.utils.stylize
function M.ruler(opts)
  opts = extend_tbl({ pad_ruler = { line = 3, char = 2 } }, opts)
  local padding_str = ("%%%dd:%%-%dd"):format(opts.pad_ruler.line, opts.pad_ruler.char)
  return function()
    local line = vim.fn.line "."
    local char = vim.fn.virtcol "."
    return status_utils.stylize(padding_str:format(line, char), opts)
  end
end

--- A provider function for showing the current location as a scrollbar
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the scrollbar
-- @usage local heirline_component = { provider = require("astroui.status").provider.scrollbar() }
-- @see astroui.status.utils.stylize
function M.scrollbar(opts)
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  return function()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #sbar) + 1
    if sbar[i] then return status_utils.stylize(sbar[i]:rep(2), opts) end
  end
end

--- A provider to simply show a close button icon
---@param opts? table options passed to the stylize function and the kind of icon to use
---@return string # the stylized icon
-- @usage local heirline_component = { provider = require("astroui.status").provider.close_button() }
-- @see astroui.status.utils.stylize
function M.close_button(opts)
  opts = extend_tbl({ kind = "BufferClose" }, opts)
  return status_utils.stylize(get_icon(opts.kind), opts)
end

--- A provider function for showing the current filetype
---@param opts? table options passed to the stylize function
---@return function  # the function for outputting the filetype
-- @usage local heirline_component = { provider = require("astroui.status").provider.filetype() }
-- @see astroui.status.utils.stylize
function M.filetype(opts)
  return function(self)
    local buffer = vim.bo[self and self.bufnr or 0]
    return status_utils.stylize(buffer.filetype:lower(), opts)
  end
end

--- A provider function for showing the current filename
---@param opts? table options for argument to fnamemodify to format filename and options passed to the stylize function
---@return function # the function for outputting the filename
-- @usage local heirline_component = { provider = require("astroui.status").provider.filename() }
-- @see astroui.status.utils.stylize
function M.filename(opts)
  opts = extend_tbl({
    fallback = "Untitled",
    fname = function(nr) return vim.api.nvim_buf_get_name(nr) end,
    modify = ":t",
  }, opts)
  return function(self)
    local path = opts.fname(self and self.bufnr or 0)
    return status_utils.stylize((path == "" and opts.fallback or vim.fn.fnamemodify(path, opts.modify)), opts)
  end
end

--- A provider function for showing the current file encoding
---@param opts? table options passed to the stylize function
---@return function  # the function for outputting the file encoding
-- @usage local heirline_component = { provider = require("astroui.status").provider.file_encoding() }
-- @see astroui.status.utils.stylize
function M.file_encoding(opts)
  return function(self)
    local buf_enc = vim.bo[self and self.bufnr or 0].fenc
    return status_utils.stylize((buf_enc ~= "" and buf_enc or vim.o.enc):upper(), opts)
  end
end

--- A provider function for showing the current file format
---@param opts? table options passed to the stylize function
---@return function  # the function for outputting the file format
-- @usage local heirline_component = { provider = require("astroui.status").provider.file_format() }
-- @see astroui.status.utils.stylize
function M.file_format(opts)
  return function(self)
    local buf_format = vim.bo[self and self.bufnr or 0].fileformat
    return status_utils.stylize((buf_format ~= "" and buf_format or vim.o.fileformat):upper(), opts)
  end
end

--- Get a unique filepath between all buffers
---@param opts? table options for function to get the buffer name, a buffer number, max length, and options passed to the stylize function
---@return function # path to file that uniquely identifies each buffer
-- @usage local heirline_component = { provider = require("astroui.status").provider.unique_path() }
-- @see astroui.status.utils.stylize
function M.unique_path(opts)
  opts = extend_tbl({
    buf_name = function(bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t") end,
    bufnr = 0,
    max_length = 16,
  }, opts)
  local function path_parts(bufnr)
    local parts = {}
    for match in (vim.api.nvim_buf_get_name(bufnr) .. "/"):gmatch("(.-)" .. "/") do
      table.insert(parts, match)
    end
    return parts
  end
  return function(self)
    local bufnr = self and self.bufnr or opts.bufnr
    local name = opts.buf_name(bufnr)
    local unique_path = ""
    -- check for same buffer names under different dirs
    local current
    for _, value in ipairs(vim.t.bufs or {}) do
      if name == opts.buf_name(value) and value ~= bufnr then
        if not current then current = path_parts(bufnr) end
        local other = path_parts(value)

        for i = #current - 1, 1, -1 do
          if current[i] ~= other[i] then
            unique_path = current[i] .. "/"
            break
          end
        end
      end
    end
    return status_utils.stylize(
      (
        opts.max_length > 0
        and #unique_path > opts.max_length
        and unique_path:sub(1, opts.max_length - 2) .. get_icon "Ellipsis" .. "/"
      ) or unique_path,
      opts
    )
  end
end

--- A provider function for showing if the current file is modifiable
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the indicator if the file is modified
-- @usage local heirline_component = { provider = require("astroui.status").provider.file_modified() }
-- @see astroui.status.utils.stylize
function M.file_modified(opts)
  opts = extend_tbl({ str = "", icon = { kind = "FileModified" }, show_empty = true }, opts)
  return function(self) return status_utils.stylize(condition.file_modified(self or {}) and opts.str or nil, opts) end
end

--- A provider function for showing if the current file is read-only
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the indicator if the file is read-only
-- @usage local heirline_component = { provider = require("astroui.status").provider.file_read_only() }
-- @see astroui.status.utils.stylize
function M.file_read_only(opts)
  opts = extend_tbl({ str = "", icon = { kind = "FileReadOnly" }, show_empty = true }, opts)
  return function(self) return status_utils.stylize(condition.file_read_only(self or {}) and opts.str or nil, opts) end
end

--- A provider function for showing the current filetype icon
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the filetype icon
-- @usage local heirline_component = { provider = require("astroui.status").provider.file_icon() }
-- @see astroui.status.utils.stylize
function M.file_icon(opts)
  return function(self)
    local devicons_avail, devicons = pcall(require, "nvim-web-devicons")
    if not devicons_avail then return "" end
    local bufnr = self and self.bufnr or 0
    local ft_icon, _ = devicons.get_icon(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t"))
    if not ft_icon then
      ft_icon, _ = devicons.get_icon_by_filetype(vim.bo[bufnr].filetype, { default = true })
    end
    return status_utils.stylize(ft_icon, opts)
  end
end

--- A provider function for showing the current git branch
---@param opts table options passed to the stylize function
---@return function # the function for outputting the git branch
-- @usage local heirline_component = { provider = require("astroui.status").provider.git_branch() }
-- @see astroui.status.utils.stylize
function M.git_branch(opts)
  return function(self) return status_utils.stylize(vim.b[self and self.bufnr or 0].gitsigns_head or "", opts) end
end

--- A provider function for showing the current git diff count of a specific type
---@param opts? table options for type of git diff and options passed to the stylize function
---@return function|nil # the function for outputting the git diff
-- @usage local heirline_component = { provider = require("astroui.status").provider.git_diff({ type = "added" }) }
-- @see astroui.status.utils.stylize
function M.git_diff(opts)
  if not opts or not opts.type then return end
  return function(self)
    local status = vim.b[self and self.bufnr or 0].gitsigns_status_dict
    return status_utils.stylize(
      status and status[opts.type] and status[opts.type] > 0 and tostring(status[opts.type]) or "",
      opts
    )
  end
end

--- A provider function for showing the current diagnostic count of a specific severity
---@param opts table options for severity of diagnostic and options passed to the stylize function
---@return function|nil # the function for outputting the diagnostic count
-- @usage local heirline_component = { provider = require("astroui.status").provider.diagnostics({ severity = "ERROR" }) }
-- @see astroui.status.utils.stylize
function M.diagnostics(opts)
  if not opts or not opts.severity then return end
  return function(self)
    local bufnr = self and self.bufnr or 0
    local count
    -- TODO: remove when dropping support for neovim 0.9
    if vim.diagnostic.count then
      count = vim.diagnostic.count(bufnr)[vim.diagnostic.severity[opts.severity]] or 0
    else
      count = #vim.diagnostic.get(bufnr, opts.severity and { severity = vim.diagnostic.severity[opts.severity] })
    end
    return status_utils.stylize(count ~= 0 and tostring(count) or "", opts)
  end
end

--- A provider function for showing the current progress of loading language servers
---@param opts? table options passed to the stylize function
---@return function # the function for outputting the LSP progress
-- @usage local heirline_component = { provider = require("astroui.status").provider.lsp_progress() }
-- @see astroui.status.utils.stylize
function M.lsp_progress(opts)
  local spinner = ui.get_spinner("LSPLoading", 1) or { "" }
  return function()
    local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
    local _, status
    if astrolsp_avail and astrolsp.lsp_progress then
      _, status = next(astrolsp.lsp_progress)
    end
    return status_utils.stylize(status and (spinner[math.floor(luv.hrtime() / 12e7) % #spinner + 1] .. table.concat({
      status.title or "",
      status.message or "",
      status.percentage and "(" .. status.percentage .. "%)" or "",
    }, " ")), opts)
  end
end

--- A provider function for showing the connected LSP client names
---@param opts? table options for explanding null_ls clients, max width percentage, and options passed to the stylize function
---@return function # the function for outputting the LSP client names
-- @usage local heirline_component = { provider = require("astroui.status").provider.lsp_client_names({ integrations = { null_ls = true, conform = true, lint = true }, truncate = 0.25 }) }
-- @see astroui.status.utils.stylize
function M.lsp_client_names(opts)
  opts = extend_tbl({
    integrations = {
      null_ls = is_available "none-ls.nvim",
      conform = is_available "conform.nvim",
      ["nvim-lint"] = is_available "nvim-lint",
    },
    truncate = 0.25,
  }, opts)
  return function(self)
    local bufnr = self and self.bufnr or 0
    local buf_client_names = {}
    -- TODO: remove get_active_clients when dropping support for Neovim 0.9
    ---@diagnostic disable-next-line: deprecated
    for _, client in pairs((vim.lsp.get_clients or vim.lsp.get_active_clients) { bufnr = bufnr }) do
      if client.name == "null-ls" and opts.integrations.null_ls then
        local null_ls_sources = {}
        for _, type in ipairs { "FORMATTING", "DIAGNOSTICS" } do
          for _, source in ipairs(status_utils.null_ls_sources(vim.bo.filetype, type)) do
            null_ls_sources[source] = true
          end
        end
        vim.list_extend(buf_client_names, vim.tbl_keys(null_ls_sources))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    if opts.integrations.conform and package.loaded["conform"] then -- conform integration
      vim.list_extend(
        buf_client_names,
        vim.tbl_map(function(c) return c.name end, require("conform").list_formatters(bufnr))
      )
    end
    if opts.integrations["nvim-lint"] and package.loaded["lint"] then -- nvim-lint integration
      vim.list_extend(buf_client_names, require("lint")._resolve_linter_by_ft(vim.bo[bufnr].filetype))
    end
    local str = table.concat(buf_client_names, ", ")
    if type(opts.truncate) == "number" then
      local max_width = math.floor(status_utils.width() * opts.truncate)
      if #str > max_width then str = str:sub(0, max_width) .. "…" end
    end
    return status_utils.stylize(str, opts)
  end
end

--- A provider function for showing the current virtual environment name
---@param opts table options passed to the stylize function
---@return function # the function for outputting the virtual environment
-- @usage local heirline_component = { provider = require("astroui.status").provider.virtual_env() }
-- @see astroui.status.utils.stylize
function M.virtual_env(opts)
  opts =
    extend_tbl({ env_names = { "env", ".env", "venv", ".venv" }, conda = { enabled = true, ignore_base = true } }, opts)
  return function()
    local conda = vim.env.CONDA_DEFAULT_ENV
    local venv = vim.env.VIRTUAL_ENV
    local env_str
    if venv then
      local path = vim.fn.split(venv, "/")
      env_str = path[#path]
      if #path > 1 and vim.tbl_contains(opts.env_names, env_str) then env_str = path[#path - 1] end
    elseif opts.conda.enabled and conda then
      if conda ~= "base" or not opts.conda.ignore_base then env_str = conda end
    end
    if env_str then return status_utils.stylize(opts.format and opts.format:format(env_str) or env_str, opts) end
  end
end

--- A provider function for showing if treesitter is connected
---@param opts? table options passed to the stylize function
---@return function # function for outputting TS if treesitter is connected
-- @usage local heirline_component = { provider = require("astroui.status").provider.treesitter_status() }
-- @see astroui.status.utils.stylize
function M.treesitter_status(opts)
  return function(self)
    return status_utils.stylize(condition.treesitter_available(self and self.bufnr or 0) and "TS" or "", opts)
  end
end

--- A provider function for displaying a single string
---@param opts? table options passed to the stylize function
---@return string # the stylized statusline string
-- @usage local heirline_component = { provider = require("astroui.status").provider.str({ str = "Hello" }) }
-- @see astroui.status.utils.stylize
function M.str(opts)
  opts = extend_tbl({ str = " " }, opts)
  return status_utils.stylize(opts.str, opts)
end

return M
