---AstroNvim Status Components
---
---Statusline related component functions to use with Heirline
---
---This module can be loaded with `local component = require "astroui.status.component"`
---
---copyright 2023
---license GNU General Public License v3.0
---@class astroui.status.component
local M = {}

local astro = require "astrocore"
local extend_tbl = astro.extend_tbl

local ui = require "astroui"
local config = assert(ui.config.status)
local init = require "astroui.status.init"
local provider = require "astroui.status.provider"
local status_utils = require "astroui.status.utils"

--- A Heirline component for filling in the empty space of the bar
---@param opts? table options for configuring the other fields of the heirline component
---@return table # The heirline component table
-- @usage local heirline_component = require("astroui.status").component.fill()
function M.fill(opts)
  return extend_tbl({ provider = provider.fill(), update = function() return false end }, opts)
end

--- A function to build a set of children components for an entire file information section
---@param opts? AstroUIComponentFileInfoOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.file_info()
function M.file_info(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "file_info"), opts)
  return M.builder(status_utils.setup_providers(opts, {
    "file_icon",
    "unique_path",
    "filename",
    "filetype",
    "file_modified",
    "file_read_only",
    "close_button",
  }))
end

--- A function with different file_info defaults specifically for use in the tabline
---@param opts? AstroUIComponentTablineFileInfoOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.tabline_file_info()
function M.tabline_file_info(opts)
  return M.file_info(extend_tbl(vim.tbl_get(config, "components", "tabline_file_info"), opts))
end

--- A function to build a set of children components for an entire navigation section
---@param opts? AstroUIComponentNavOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.nav()
function M.nav(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "nav"), opts)
  return M.builder(status_utils.setup_providers(opts, { "ruler", "percentage", "scrollbar" }))
end

--- A function to build a set of children components for information shown in the cmdline
---@param opts? AstroUIComponentCmdInfoOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.cmd_info()
function M.cmd_info(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "cmd_info"), opts)
  return M.builder(status_utils.setup_providers(opts, { "macro_recording", "search_count", "showcmd" }))
end

--- A function to build a set of children components for a mode section
---@param opts? AstroUIComponentModeOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.mode { mode_text = true }
function M.mode(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "mode"), opts)
  if not opts["mode_text"] then opts.str = { str = " " } end
  return M.builder(status_utils.setup_providers(opts, { "mode_text", "str", "paste", "spell" }))
end

--- A function to build a set of children components for an LSP breadcrumbs section
---@param opts? AstroUIComponentBreadcrumbsOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.breadcrumbs()
function M.breadcrumbs(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "breadcrumbs"), opts)
  opts.init = init.breadcrumbs(opts)
  return opts
end

--- A function to build a set of children components for the current file path
---@param opts? AstroUIComponentSeparatedPathOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.separated_path()
function M.separated_path(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "separated_path"), opts)
  opts.init = init.separated_path(opts)
  return opts
end

--- A function to build a set of children components for a git branch section
---@param opts? AstroUIComponentGitBranchOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.git_branch()
function M.git_branch(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "git_branch"), opts)
  return M.builder(status_utils.setup_providers(opts, { "git_branch" }))
end

--- A function to build a set of children components for a git difference section
---@param opts? AstroUIComponentGitDiffOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.git_diff()
function M.git_diff(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "git_diff"), opts)
  return M.builder(status_utils.setup_providers(opts, { "added", "changed", "removed" }, function(p_opts, p)
    local out = status_utils.build_provider(p_opts, p)
    if out then
      out.provider = "git_diff"
      out.opts.type = p
      if out.hl == nil then out.hl = { fg = "git_" .. p } end
    end
    return out
  end))
end

--- A function to build a set of children components for a diagnostics section
---@param opts? AstroUIComponentDiagnosticsOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.diagnostics()
function M.diagnostics(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "diagnostics"), opts)
  return M.builder(status_utils.setup_providers(opts, { "ERROR", "WARN", "INFO", "HINT" }, function(p_opts, p)
    local out = status_utils.build_provider(p_opts, p)
    if out then
      out.provider = "diagnostics"
      out.opts.severity = p
      if out.hl == nil then out.hl = { fg = "diag_" .. p } end
    end
    return out
  end))
end

--- A function to build a set of children components for a Treesitter section
---@param opts? AstroUIComponentTreesitterOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.treesitter()
function M.treesitter(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "treesitter"), opts)
  return M.builder(status_utils.setup_providers(opts, { "str" }))
end

--- A function to build a set of children components for an LSP section
---@param opts? AstroUIComponentLspOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.lsp()
function M.lsp(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "lsp"), opts)
  return M.builder(status_utils.setup_providers(
    opts,
    { "lsp_progress", "lsp_client_names" },
    function(p_opts, p, i)
      return p_opts
          and {
            flexible = i,
            status_utils.build_provider(p_opts, provider[p](p_opts)),
            status_utils.build_provider(p_opts, provider.str(p_opts)),
          }
        or false
    end
  ))
end

--- A function to build a set of children components for a git branch section
---@param opts? AstroUIComponentVirtualEnvOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.git_branch()
function M.virtual_env(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "virtual_env"), opts)
  return M.builder(status_utils.setup_providers(opts, { "virtual_env" }))
end

--- A function to build a set of components for a foldcolumn section in a statuscolumn
---@param opts? AstroUIComponentFoldcolumnOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.foldcolumn()
function M.foldcolumn(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "foldcolumn"), opts)
  return M.builder(status_utils.setup_providers(opts, { "foldcolumn" }))
end

--- A function to build a set of components for a numbercolumn section in statuscolumn
---@param opts? AstroUIComponentNumbercolumnOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.numbercolumn()
function M.numbercolumn(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "numbercolumn"), opts)
  return M.builder(status_utils.setup_providers(opts, { "numbercolumn" }))
end

--- A function to build a set of components for a signcolumn section in statuscolumn
---@param opts? AstroUIComponentSigncolumnOpts provider options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").component.signcolumn()
function M.signcolumn(opts)
  opts = extend_tbl(vim.tbl_get(config, "components", "signcolumn"), opts)
  return M.builder(status_utils.setup_providers(opts, { "signcolumn" }))
end

--- A general function to build a section of astronvim status providers with highlights, conditions, and section surrounding
---@param opts? AstroUIComponentBuilderOpts component builder options
---@return table # The Heirline component table
-- @usage local heirline_component = require("astroui.status").components.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })
function M.builder(opts)
  opts = extend_tbl({ padding = { left = 0, right = 0 } }, opts)
  local children, offset = {}, 0
  if opts.padding.left > 0 then -- add left padding
    table.insert(children, { provider = status_utils.pad_string(" ", { left = opts.padding.left - 1 }) })
    offset = offset + 1
  end
  for key, entry in pairs(opts) do
    if
      type(key) == "number"
      and type(entry) == "table"
      and provider[entry.provider]
      and (entry.opts == nil or type(entry.opts) == "table")
    then
      entry.provider = provider[entry.provider](entry.opts)
    end
    if type(key) == "number" then key = key + offset end
    children[key] = entry
  end
  if opts.padding.right > 0 then -- add right padding
    table.insert(children, { provider = status_utils.pad_string(" ", { right = opts.padding.right - 1 }) })
  end
  return opts.surround
      and status_utils.surround(
        opts.surround.separator,
        opts.surround.color,
        children,
        opts.surround.condition,
        opts.surround.update
      )
    or children
end

return M
