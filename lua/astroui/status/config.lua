-- AstroNvim UI Status Configuration
--
-- This module simply defines the configuration table structure for `opts.status` used in:
--
--    require("astroui").setup(opts)
--
-- copyright 2023
-- license GNU General Public License v3.0

---@class AstroUIStatusPadding
---@field left integer? number of spaces to pad to the left
---@field right integer? number of spaces to pad to the right

---@class AstroUIStatusIcon
---@field kind string? the icon name as set in the AstroUI icons
---@field padding AstroUIStatusPadding? padding settings to apply to the icon

---@class AstroUIStatusStylizeOpts
---@field padding AstroUIStatusPadding? padding settings to apply to the string
---@field separator { left: string?, right: string? }? the separator characters to the left and right of the string
---@field escape boolean? whether to escape the provided string for special character handling or to return the string as is
---@field show_empty boolean? whether to show empty strings with padding and separators or just return and empty string
---@field icon AstroUIStatusIcon? icon settings to prepend to the string

---@class AstroUIProviderSigncolumnOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderNumbercolumnOpts: AstroUIStatusStylizeOpts
---@field thousands string|false? a string separator for numbers >= 1,000
---@field culright boolean? whether to right align the current line number

---@class AstroUIProviderFoldcolumnOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderSpellOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderPasteOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderMacroRecordingOpts: AstroUIStatusStylizeOpts
---@field prefix string? a character to prefix before a register

---@class AstroUIProviderShowcmdOpts: AstroUIStatusStylizeOpts
---@field minwid integer? minimum width
---@field maxwid integer? maximum width

---@class AstroUIProviderSearchCountOpts: AstroUIStatusStylizeOpts
---@field recompute boolean? Always recompute when calculating search (default: True)
---@field pattern string? Specify a pattern (default: `@/`)
---@field timeout integer? timeout in milliseconds, negative or 0 is no timeout (default: 0)
---@field maxcount integer? limit of matches, negative or 0 is no limit (default: 0)
---@field pos integer[]? position list ([lnum, col, off]) see `:h cursor()` for details (default: current position)

---@class AstroUIProviderModeTextOpts: AstroUIStatusStylizeOpts
---@field pad_text "right"|"left"|"center"|false? alignment of mode text

---@class AstroUIProviderPercentageOpts: AstroUIStatusStylizeOpts
---@field edge_text boolean? whether to show "Top"/"Bot" when on the first/last line

---@class AstroUIProviderRulerOpts: AstroUIStatusStylizeOpts
---@field pad_ruler { line: integer?, char: integer? }? padding to apply to line and character values

---@class AstroUIProviderScrollbarOpts: AstroUIStatusStylizeOpts
---@field chars string[]? characters to use for the scrollbar, ordered from bottom to top

---@class AstroUIProviderCloseButtonOpts: AstroUIStatusStylizeOpts
---@field kind string? the icon kind to use for the close button as defined in AstroUI icons

---@class AstroUIProviderFiletypeOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderFilenameOpts: AstroUIStatusStylizeOpts
---@field fname (fun(bufnr: integer): string)? function for calculating the buffer name
---@field modify string? modifiers to pass to `fnamemodify` on final path
---@field fallback string? Fallback string for when a buffer does not have a filename

---@class AstroUIProviderFileEncodingOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderFileFormatOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderUniquePathOpts: AstroUIStatusStylizeOpts
---@field bufnr integer? the buffer number to fallback to if not provided to provider function
---@field buf_name (fun(bufnr: integer): string)? function for calculating buffer name
---@field max_length integer? maximum length before truncating with ellipsis

---@class AstroUIProviderFileModifiedOpts: AstroUIStatusStylizeOpts
---@field str string? the string to display when file is modified

---@class AstroUIProviderFileReadOnlyOpts: AstroUIStatusStylizeOpts
---@field str string? the string to display when file is read only

---@class AstroUIProviderFileIconOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderGitBranchOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderGitDiffOpts: AstroUIStatusStylizeOpts
---@field type "added"|"changed"|"removed"? the type of diff to display

---@class AstroUIProviderDiagnosticsOpts: AstroUIStatusStylizeOpts
---@field severity "ERROR"|"WARN"|"INFO"|"HINT"? the diagnostic severity to display

---@class AstroUIProviderLspProgressOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderLspClientNamesOpts: AstroUIStatusStylizeOpts
---@field integrations { null_ls: boolean?, conform: boolean?, nvim-lint: boolean? } enable or disable client name integrations
---@field mappings { [string]: (string|fun(client: string): string)? }? add custom client name mappings ("*" will apply to all as a fallback)
---@field truncate number? percentage of statusline of the maximum width before truncation with ellipsis

---@class AstroUIProviderVirtualEnvOpts: AstroUIStatusStylizeOpts
---@field env_names string[]? base environment names to replace with the project directory name
---@field conda { enabled: boolean?, ignore_base: boolean? }? enable/disable conda environments and base conda environment
---@field format (fun(env: string): string)? function to customize formatting of environment name

---@class AstroUIProviderTreesitterStatusOpts: AstroUIStatusStylizeOpts

---@class AstroUIProviderStrOpts: AstroUIStatusStylizeOpts
---@field str string the static string to display

---@class AstroUIProviders
---@field signcolumn AstroUIProviderSigncolumnOpts? default options for the `signcolumn` provider
---@field numbercolumn AstroUIProviderNumbercolumnOpts? default options for the `numbercolumn` provider
---@field foldcolumn AstroUIProviderSigncolumnOpts? default options for the `foldcolumn` provider
---@field spell AstroUIProviderSpellOpts? default options for the `spell` provider
---@field paste AstroUIProviderSpellOpts? default options for the `paste` provider
---@field macro_recording AstroUIProviderMacroRecordingOpts? default options for the `macro_recording` provider
---@field showcmd AstroUIProviderShowcmdOpts? default options for the `showcmd` provider
---@field search_count AstroUIProviderSearchCountOpts? default options for the `search_count` provider
---@field mode_text AstroUIProviderModeTextOpts? default options for the `mode_text` provider
---@field percentage AstroUIProviderPercentageOpts? default options for the `percentage` provider
---@field ruler AstroUIProviderRulerOpts? default options for the `ruler` provider
---@field scrollbar AstroUIProviderScrollbarOpts? default options for the `scrollbar` provider
---@field close_button AstroUIProviderCloseButtonOpts? default options for the `close_button` provider
---@field filetype AstroUIProviderFiletypeOpts? default options for the `filetype` provider
---@field filename AstroUIProviderFilenameOpts? default options for the `filename` provider
---@field file_encoding AstroUIProviderFileEncodingOpts? default options for the `file_encoding` provider
---@field file_format AstroUIProviderFileFormatOpts? default options for the `file_format` provider
---@field unique_path AstroUIProviderUniquePathOpts? default options for the `unique_path` provider
---@field file_modified AstroUIProviderFileModifiedOpts? default options for the `file_modified` provider
---@field file_read_only AstroUIProviderFileReadOnlyOpts? default options for the `file_read_only` provider
---@field file_icon AstroUIProviderFileIconOpts? default options for the `file_icon` provider
---@field git_branch AstroUIProviderGitBranchOpts? default options for the `git_branch` provider
---@field git_diff AstroUIProviderGitDiffOpts? default options for the `git_diff` provider
---@field diagnostics AstroUIProviderDiagnosticsOpts? default options for the `diagnostics` provider
---@field lsp_progress AstroUIProviderLspProgressOpts? default options for the `lsp_progress` provider
---@field lsp_client_names AstroUIProviderLspClientNamesOpts? default options for the `lsp_client_names` provider
---@field virtual_env AstroUIProviderVirtualEnvOpts? default options for the `virtual_env` provider
---@field treesitter_status AstroUIProviderTreesitterStatusOpts? default options for the `treesitter_status` provider
---@field str AstroUIProviderStrOpts? default options for the `str` provider

---@class AstroUISeparators
---@field none string[]? placeholder separator for elements with "no" separator, typically two empty strings
---@field left string[]? Separators used for elements designated as being on the left of the statusline
---@field right string[]? Separators used for elements designated as being on the right of the statusline
---@field center string[]? Separators used for elements designated as being in the center of the statusline
---@field tab string[]? Separators used for tabs rendered in the tabline
---@field breadcrumbs string? Separator used in between symbols in the breadcrumbs
---@field path string? Separator used in between symbols in a file path

---@class AstroUIWinbar
---@field enabled table<BufMatcherKinds, BufMatcherPattern[]>? Buffer matching patterns for whitelisting buffers to enable winbar
---@field disabled table<BufMatcherKinds, BufMatcherPattern[]>? Buffer matching patterns for blacklisting buffers from enabling winbar

---@class AstroUIStatusOpts
---Configure attributes of components defined in the `status` API. Check the AstroNvim documentation for a complete list of color names, this applies to colors that have `_fg` and/or `_bg` names with the suffix removed (ex. `git_branch_fg` as attributes from `git_branch`).
---Example:
---
---```lua
---attributes = {
---  git_branch = { bold = true },
---}
---```
---@field attributes table<string,table>?
---Configure colors of components defined in the `status` API. Check the AstroNvim documentation for a complete list of color names.
---Example:
---
---```lua
---colors = {
---  git_branch_fg = "#ABCDEF",
---}
---```
---@field colors (StringMap|(fun(colors:StringMap):StringMap?))?
---Set up the default configuration options for the provided statusline components.
---TODO: this field still needs to add strong typing
---Example:
---```lua
---components = {
---  file_info = {
---    file_read_only = false
---  }
---}
---```
---@field components table?
---**MEANT FOR INTERNAL USE ONLY**
---A table of fallback colors if a colorscheme used by the user does not have a highlight group, the entry point to this are typically through the `status.colors` option.
---@field fallback_colors StringMap?
---Configure which icons that are highlighted based on context
---Example:
---
---```lua
---icon_highlights = {
---  breadcrumbs = false,
---  file_icon = {
---    tabline = function(self) return self.is_active or self.is_visible end,
---    statusline = true,
---  }
---}
---```
---@field icon_highlights AstroUIIconHighlights?
---**MEANT FOR INTERNAL USE ONLY**
---Conversion table of vim mode text to readable text and color name to be used
---Example:
---
---```lua
---modes = {
---  ["n"] = {
---    "NORMAL", -- readable name
---    "normal", -- color name
---  },
---  ["no"] = {
---    "OP",     -- readable name
---    "normal", -- color name
---  }
---}
---```
---@field modes table<string,string[]>?
---Set up the default configuration options for the provided statusline providers.
---TODO: this field still needs to add strong typing
---Example:
---```lua
---providers = {
---  lsp_client_names = {
---    mappings = {
---      ruff_organize_imports = "ruff"
---    }
---  }
---}
---```
---@field providers AstroUIProviders?
---Configure characters used as separators for various elements
---Example:
---
---```lua
---separators = {
---  none = { "", "" },
---  left = { "", "  " },
---  right = { "  ", "" },
---  center = { "  ", "  " },
---  tab = { "", "" },
---  breadcrumbs = "  ",
---  path = "  ",
---}
---```
---@field separators AstroUISeparators?
---Configure when winbar is enabled/disabled
---@field winbar AstroUIWinbar?
---**MEANT FOR INTERNAL USE ONLY**
---Function used for setting up colors in Heirline, the entry point to this are typically through the `status.colors` option.
---@field setup_colors (fun():StringMap)?
---**MEANT FOR INTERNAL USE ONLY**
---A collection of click handlers for internal heirline components such as `gitsigns`, `diagnostics`, and `dap`
---@field sign_handlers table<string,fun(args:table)>?

---@type AstroUIStatusOpts
return {
  attributes = {},
  colors = {},
  components = {
    file_info = {
      file_icon = {
        hl = function(self) return require("astroui.status.hl").file_icon "statusline"(self) end,
        padding = { left = 1, right = 1 },
      },
      filename = false,
      filetype = {},
      file_modified = {
        padding = { left = 1 },
        condition = function(...) return require("astroui.status.condition").is_file(...) end,
      },
      file_read_only = {
        padding = { left = 1 },
        condition = function(...) return require("astroui.status.condition").is_file(...) end,
      },
      surround = {
        separator = "left",
        color = "file_info_bg",
        condition = function(...) return require("astroui.status.condition").has_filetype(...) end,
      },
      hl = function() return require("astroui.status.hl").get_attributes "file_info" end,
    },
    tabline_file_info = {
      file_icon = {
        condition = function(self) return not self._show_picker end,
        hl = function(self) return require("astroui.status.hl").file_icon "tabline"(self) end,
      },
      filename = {},
      filetype = false,
      unique_path = {
        hl = function(self) return require("astroui.status.hl").get_attributes(self.tab_type .. "_path") end,
      },
      close_button = {
        hl = function(self) return require("astroui.status.hl").get_attributes(self.tab_type .. "_close") end,
        padding = { left = 1, right = 1 },
        on_click = {
          callback = function(_, minwid) require("astrocore.buffer").close(minwid) end,
          minwid = function(self) return self.bufnr end,
          name = "heirline_tabline_close_buffer_callback",
        },
      },
      padding = { right = 1 },
      hl = function(self)
        local tab_type = self.tab_type
        if self._show_picker and self.tab_type ~= "buffer_active" then tab_type = "buffer_visible" end
        return require("astroui.status.hl").get_attributes(tab_type)
      end,
      surround = false,
    },
    nav = {
      ruler = {},
      percentage = { padding = { left = 1 } },
      scrollbar = { padding = { left = 1 }, hl = { fg = "scrollbar" } },
      surround = { separator = "right", color = "nav_bg" },
      hl = function() return require("astroui.status.hl").get_attributes "nav" end,
      update = { "CursorMoved", "CursorMovedI", "BufEnter" },
    },
    cmd_info = {
      macro_recording = {
        icon = { kind = "MacroRecording", padding = { right = 1 } },
        condition = function() return require("astroui.status.condition").is_macro_recording() end,
        update = { "RecordingEnter", "RecordingLeave" },
      },
      search_count = {
        icon = { kind = "Search", padding = { right = 1 } },
        padding = { left = 1 },
        condition = function() return require("astroui.status.condition").is_hlsearch() end,
      },
      showcmd = {
        padding = { left = 1 },
        condition = function() return require("astroui.status.condition").is_statusline_showcmd() end,
      },
      surround = {
        separator = "center",
        color = "cmd_info_bg",
        condition = function()
          local condition = require "astroui.status.condition"
          return condition.is_hlsearch() or condition.is_macro_recording() or condition.is_statusline_showcmd()
        end,
      },
      condition = function() return vim.opt.cmdheight:get() == 0 end,
      hl = function() return require("astroui.status.hl").get_attributes "cmd_info" end,
    },
    mode = {
      mode_text = false,
      paste = false,
      spell = false,
      surround = {
        separator = "left",
        color = function() return require("astroui.status.hl").mode_bg() end,
        update = { "ModeChanged", pattern = "*:*" },
      },
      hl = function() return require("astroui.status.hl").get_attributes "mode" end,
      update = {
        "ModeChanged",
        pattern = "*:*",
        callback = function() vim.schedule(vim.cmd.redrawstatus) end,
      },
    },
    breadcrumbs = {
      padding = { left = 1 },
      condition = function() return require("astroui.status.condition").aerial_available() end,
      update = "CursorMoved",
    },
    separated_path = { padding = { left = 1 }, update = { "BufEnter", "DirChanged" } },
    git_branch = {
      git_branch = { icon = { kind = "GitBranch", padding = { right = 1 } } },
      surround = {
        separator = "left",
        color = "git_branch_bg",
        condition = function(...) return require("astroui.status.condition").is_git_repo(...) end,
      },
      hl = function() return require("astroui.status.hl").get_attributes "git_branch" end,
      on_click = {
        name = "heirline_branch",
        callback = function()
          local fzf_lua_avail, fzf_lua = pcall(require, "fzf-lua")
          if fzf_lua_avail then
            fzf_lua.git_branches()
            return
          end

          local telescope_avail, telescope_builtin = pcall(require, "telescope.builtin")
          if telescope_avail then
            telescope_builtin.git_branches { use_file_path = true }
            return
          end

          local snacks_avail, snacks = pcall(require, "snacks")
          if snacks_avail then
            snacks.picker.git_branches()
            return
          end
        end,
      },
      update = {
        "User",
        pattern = { "GitSignsUpdate", "GitSignsChanged" },
        callback = function() vim.schedule(vim.cmd.redrawstatus) end,
      },
      init = function(...) return require("astroui.status.init").update_events { "BufEnter" }(...) end,
    },
    git_diff = {
      added = { icon = { kind = "GitAdd", padding = { left = 1, right = 1 } } },
      changed = { icon = { kind = "GitChange", padding = { left = 1, right = 1 } } },
      removed = { icon = { kind = "GitDelete", padding = { left = 1, right = 1 } } },
      hl = function() return require("astroui.status.hl").get_attributes "git_diff" end,
      on_click = {
        name = "heirline_git",
        callback = function()
          local fzf_lua_avail, fzf_lua = pcall(require, "fzf-lua")
          if fzf_lua_avail then
            fzf_lua.git_status()
            return
          end

          local telescope_avail, telescope_builtin = pcall(require, "telescope.builtin")
          if telescope_avail then
            telescope_builtin.git_status { use_file_path = true }
            return
          end

          local snacks_avail, snacks = pcall(require, "snacks")
          if snacks_avail then
            snacks.picker.git_status()
            return
          end
        end,
      },
      surround = {
        separator = "left",
        color = "git_diff_bg",
        condition = function(...) return require("astroui.status.condition").git_changed(...) end,
      },
      update = {
        "User",
        pattern = { "GitSignsUpdate", "GitSignsChanged", "MiniDiffUpdated" },
        callback = function() vim.schedule(vim.cmd.redrawstatus) end,
      },
      init = function(...) return require("astroui.status.init").update_events { "BufEnter" }(...) end,
    },
    diagnostics = {
      ERROR = { icon = { kind = "DiagnosticError", padding = { left = 1, right = 1 } } },
      WARN = { icon = { kind = "DiagnosticWarn", padding = { left = 1, right = 1 } } },
      INFO = { icon = { kind = "DiagnosticInfo", padding = { left = 1, right = 1 } } },
      HINT = { icon = { kind = "DiagnosticHint", padding = { left = 1, right = 1 } } },
      surround = {
        separator = "left",
        color = "diagnostics_bg",
        condition = function(...) return require("astroui.status.condition").has_diagnostics(...) end,
      },
      hl = function() return require("astroui.status.hl").get_attributes "diagnostics" end,
      on_click = {
        name = "heirline_diagnostic",
        callback = function()
          local fzf_lua_avail, fzf_lua = pcall(require, "fzf-lua")
          if fzf_lua_avail then
            fzf_lua.diagnostics_document()
            return
          end

          local telescope_avail, telescope_builtin = pcall(require, "telescope.builtin")
          if telescope_avail then
            telescope_builtin.diagnostics { bufnr = 0 }
            return
          end

          local snacks_avail, snacks = pcall(require, "snacks")
          if snacks_avail then
            snacks.picker.diagnostics_buffer()
            return
          end
        end,
      },
      update = { "DiagnosticChanged", "BufEnter" },
    },
    treesitter = {
      str = { str = "TS", icon = { kind = "ActiveTS", padding = { right = 1 } } },
      surround = {
        separator = "right",
        color = "treesitter_bg",
        condition = function(...) return require("astroui.status.condition").treesitter_available(...) end,
      },
      hl = function() return require("astroui.status.hl").get_attributes "treesitter" end,
      update = { "OptionSet", pattern = "syntax" },
      init = function(...) return require("astroui.status.init").update_events { "BufEnter" }(...) end,
    },
    lsp = {
      lsp_progress = {
        str = "",
        padding = { right = 1 },
        update = {
          "User",
          pattern = "AstroLspProgress",
          callback = function() vim.schedule(vim.cmd.redrawstatus) end,
        },
      },
      lsp_client_names = {
        str = "LSP",
        update = {
          "LspAttach",
          "LspDetach",
          "BufEnter",
          "FileType",
          "VimResized",
          callback = function() vim.schedule(vim.cmd.redrawstatus) end,
        },
        icon = { kind = "ActiveLSP", padding = { right = 2 } },
      },
      hl = function() return require("astroui.status.hl").get_attributes "lsp" end,
      surround = {
        separator = "right",
        color = "lsp_bg",
        condition = function(...) return require("astroui.status.condition").lsp_attached(...) end,
      },
      on_click = {
        name = "heirline_lsp",
        callback = function() vim.schedule(vim.cmd.LspInfo) end,
      },
    },
    virtual_env = {
      virtual_env = { icon = { kind = "Environment", padding = { right = 1 } } },
      surround = {
        separator = "right",
        color = "virtual_env_bg",
        condition = function() return require("astroui.status.condition").has_virtual_env() end,
      },
      hl = function() return require("astroui.status.hl").get_attributes "virtual_env" end,
      on_click = {
        name = "heirline_virtual_env",
        callback = function()
          if vim.fn.exists ":VenvSelect" > 0 then vim.schedule(vim.cmd.VenvSelect) end
        end,
      },
    },
    foldcolumn = {
      foldcolumn = { padding = { right = 1 } },
      condition = function() return require("astroui.status.condition").foldcolumn_enabled() end,
      on_click = {
        name = "fold_click",
        callback = function(...)
          local get_icon = require("astroui").get_icon
          local char = require("astroui.status.utils").statuscolumn_clickargs(...).char
          local fillchars = vim.opt_local.fillchars:get()
          if char == (fillchars.foldopen or get_icon "FoldOpened") then
            vim.cmd "norm! zc"
          elseif char == (fillchars.foldclose or get_icon "FoldClosed") then
            vim.cmd "norm! zo"
          end
        end,
      },
    },
    numbercolumn = {
      numbercolumn = { padding = { right = 1 } },
      condition = function() return require("astroui.status.condition").numbercolumn_enabled() end,
      on_click = {
        name = "line_click",
        callback = function(...)
          local args = require("astroui.status.utils").statuscolumn_clickargs(...)
          if args.mods:find "c" then
            local dap_avail, dap = pcall(require, "dap")
            if dap_avail then dap.toggle_breakpoint() end
          end
        end,
      },
    },
    signcolumn = {
      signcolumn = {},
      condition = function() return require("astroui.status.condition").signcolumn_enabled() end,
      on_click = {
        name = "sign_click",
        callback = function(...)
          local args = require("astroui.status.utils").statuscolumn_clickargs(...)
          local config = assert(require("astroui").config.status)
          if args.sign then
            local handler = args.sign.name ~= "" and config.sign_handlers[args.sign.name]
            if not handler then handler = config.sign_handlers[args.sign.namespace] end
            if not handler then handler = config.sign_handlers[args.sign.texthl] end
            if handler then handler(args) end
          end
        end,
      },
    },
  },
  fallback_colors = {},
  icon_highlights = {},
  modes = {},
  providers = {
    signcolumn = { escape = false },
    numbercolumn = { thousands = false, culright = true, escape = false },
    foldcolumn = { escape = false },
    spell = { str = "", icon = { kind = "Spellcheck" }, show_empty = true },
    paste = { str = "", icon = { kind = "Paste" }, show_empty = true },
    macro_recording = { prefix = "@" },
    showcmd = { minwid = 0, maxwid = 5, escape = false },
    search_count = {},
    mode_text = { pad_text = false },
    percentage = { escape = false, fixed_width = true, edge_text = true },
    ruler = { pad_ruler = { line = 3, char = 2 } },
    scrollbar = { chars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" } },
    close_button = { kind = "BufferClose" },
    filename = {
      fallback = "Untitled",
      fname = function(bufnr) return vim.api.nvim_buf_get_name(bufnr) end,
      modify = ":t",
    },
    unique_path = {
      buf_name = function(bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t") end,
      bufnr = 0,
      max_length = 16,
    },
    file_modified = { str = "", icon = { kind = "FileModified" }, show_empty = true },
    file_read_only = { str = "", icon = { kind = "FileReadOnly" }, show_empty = true },
    lsp_client_names = {
      mappings = {},
      integrations = { null_ls = true, conform = true, ["nvim-lint"] = true },
      truncate = 0.25,
    },
    virtual_env = { env_names = { "env", ".env", "venv", ".venv" }, conda = { enabled = true, ignore_base = true } },
    str = { str = " " },
  },
  separators = {},
  setup_colors = nil,
  sign_handlers = {},
  winbar = {},
}
