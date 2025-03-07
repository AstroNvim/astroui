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
---@field providers table?
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
  status = {
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
  },
  lazygit = false,
}

return M
