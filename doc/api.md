# Lua API

astroui API documentation

## astroui

AstroNvim UI Utilities

UI utility functions to use within AstroNvim and user configurations.

This module can be loaded with `local astro = require "astroui"`

copyright 2023
license GNU General Public License v3.0

### config


```lua
AstroUIOpts
```

### get_icon


```lua
function astroui.get_icon(kind: string, padding?: integer, no_fallback?: boolean)
  -> icon: string
```

 Get an icon from the AstroNvim internal icons if it is available and return it

*param* `kind` — The kind of icon in astroui.icons to retrieve

*param* `padding` — Padding to add to the end of the icon

*param* `no_fallback` — Whether or not to disable fallback to text icon

### get_spinner


```lua
function astroui.get_spinner(kind: string, ...any)
  -> spinners: string[]|nil
```

 Get a icon spinner table if it is available in the AstroNvim icons. Icons in format `kind1`,`kind2`, `kind3`, ...

*param* `kind` — The kind of icon to check for sequential entries of

*return* `spinners` — A collected table of spinning icons in sequential order or nil if none exist

### setup


```lua
function astroui.setup(opts: AstroUIOpts)
```

 Setup and configure AstroUI


## astroui.status.component

AstroNvim Status Components

Statusline related component functions to use with Heirline

This module can be loaded with `local component = require "astroui.status.component"`

copyright 2023
license GNU General Public License v3.0

### breadcrumbs


```lua
function astroui.status.component.breadcrumbs(opts?: table)
  -> table
```

 A function to build a set of children components for an LSP breadcrumbs section

*param* `opts` — options for configuring breadcrumbs and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.breadcumbs()

### builder


```lua
function astroui.status.component.builder(opts?: table)
  -> table
```

 A general function to build a section of astronvim status providers with highlights, conditions, and section surrounding

*param* `opts` — a list of components to build into a section

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").components.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })

### cmd_info


```lua
function astroui.status.component.cmd_info(opts?: table)
  -> table
```

 A function to build a set of children components for information shown in the cmdline

*param* `opts` — options for configuring macro recording, search count, and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.cmd_info()

### diagnostics


```lua
function astroui.status.component.diagnostics(opts?: table)
  -> table
```

 A function to build a set of children components for a diagnostics section

*param* `opts` — options for configuring diagnostic providers and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.diagnostics()

### file_info


```lua
function astroui.status.component.file_info(opts?: table)
  -> table
```

 A function to build a set of children components for an entire file information section

*param* `opts` — options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.file_info()

### fill


```lua
function astroui.status.component.fill(opts?: table)
  -> table
```

 A Heirline component for filling in the empty space of the bar

*param* `opts` — options for configuring the other fields of the heirline component

*return* — The heirline component table

 @usage local heirline_component = require("astroui.status").component.fill()

### foldcolumn


```lua
function astroui.status.component.foldcolumn(opts?: table)
  -> table
```

 A function to build a set of components for a foldcolumn section in a statuscolumn

*param* `opts` — options for configuring foldcolumn and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.foldcolumn()

### git_branch


```lua
function astroui.status.component.git_branch(opts?: table)
  -> table
```

 A function to build a set of children components for a git branch section

*param* `opts` — options for configuring git branch and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.git_branch()

### git_diff


```lua
function astroui.status.component.git_diff(opts?: table)
  -> table
```

 A function to build a set of children components for a git difference section

*param* `opts` — options for configuring git changes and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.git_diff()

### lsp


```lua
function astroui.status.component.lsp(opts?: table)
  -> table
```

 A function to build a set of children components for an LSP section

*param* `opts` — options for configuring lsp progress and client_name providers and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.lsp()

### mode


```lua
function astroui.status.component.mode(opts?: table)
  -> table
```

 A function to build a set of children components for a mode section

*param* `opts` — options for configuring mode_text, paste, spell, and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.mode { mode_text = true }

### nav


```lua
function astroui.status.component.nav(opts?: table)
  -> table
```

 A function to build a set of children components for an entire navigation section

*param* `opts` — options for configuring ruler, percentage, scrollbar, and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.nav()

### numbercolumn


```lua
function astroui.status.component.numbercolumn(opts?: table)
  -> table
```

 A function to build a set of components for a numbercolumn section in statuscolumn

*param* `opts` — options for configuring numbercolumn and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.numbercolumn()

### separated_path


```lua
function astroui.status.component.separated_path(opts?: table)
  -> table
```

 A function to build a set of children components for the current file path

*param* `opts` — options for configuring path and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.separated_path()

### signcolumn


```lua
function astroui.status.component.signcolumn(opts?: table)
  -> table
```

 A function to build a set of components for a signcolumn section in statuscolumn

*param* `opts` — options for configuring signcolumn and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.signcolumn()

### tabline_file_info


```lua
function astroui.status.component.tabline_file_info(opts?: table)
  -> table
```

 A function with different file_info defaults specifically for use in the tabline

*param* `opts` — options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.tabline_file_info()

### treesitter


```lua
function astroui.status.component.treesitter(opts?: table)
  -> table
```

 A function to build a set of children components for a Treesitter section

*param* `opts` — options for configuring diagnostic providers and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.treesitter()

### virtual_env


```lua
function astroui.status.component.virtual_env(opts?: table)
  -> table
```

 A function to build a set of children components for a git branch section

*param* `opts` — options for configuring git branch and the overall padding

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.git_branch()


## astroui.status.condition

AstroNvim Status Conditions

Statusline related condition functions to use with Heirline

This module can be loaded with `local condition = require "astroui.status.condition"`

copyright 2023
license GNU General Public License v3.0

### aerial_available


```lua
function astroui.status.condition.aerial_available()
  -> boolean
```

 A condition function if Aerial is available

*return* — whether or not aerial plugin is installed

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.aerial_available }
 function M.aerial_available() return is_available "aerial.nvim" end

### buffer_matches


```lua
function astroui.status.condition.buffer_matches(patterns: table<"bufname"|"buftype"|"filetype", string|string[]>, bufnr?: integer, op?: "and"|"or")
  -> boolean
```

 A condition function if the buffer filetype,buftype,bufname match a pattern

*param* `patterns` — the table of patterns to match

*param* `bufnr` — of the buffer to match (Default: 0 [current])

*param* `op` — whether or not to require all pattern types to match or any (Default: "or")

*return* — whether or not LSP is attached

 @usage local heirline_component = { provider = "Example Provider", condition = function() return require("astroui.status").condition.buffer_matches { buftype = { "terminal" } } end }

```lua
op:
    | "and"
    | "or"
```

### file_modified


```lua
function astroui.status.condition.file_modified(bufnr: integer|table)
  -> boolean
```

 A condition function if the current buffer is modified

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not the current buffer is modified

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.file_modified }

### file_read_only


```lua
function astroui.status.condition.file_read_only(bufnr: integer|table)
  -> boolean
```

 A condition function if the current buffer is read only

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not the current buffer is read only or not modifiable

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.file_read_only }

### foldcolumn_enabled


```lua
function astroui.status.condition.foldcolumn_enabled()
  -> boolean
```

 A condition function if the foldcolumn is enabled

*return* — true if vim.opt.foldcolumn > 0, false if vim.opt.foldcolumn == 0

### git_changed


```lua
function astroui.status.condition.git_changed(bufnr: integer|table)
  -> boolean
```

 A condition function if there are any git changes

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not there are any git changes

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.git_changed }

### has_diagnostics


```lua
function astroui.status.condition.has_diagnostics(bufnr: integer|table)
  -> boolean
```

 A condition function if the current file has any diagnostics

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not the current file has any diagnostics

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.has_diagnostics }

### has_filetype


```lua
function astroui.status.condition.has_filetype(bufnr: integer|table)
  -> boolean
```

 A condition function if there is a defined filetype

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not there is a filetype

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.has_filetype }

### has_virtual_env


```lua
function astroui.status.condition.has_virtual_env()
  -> boolean
```

 A condition function if a virtual environment is activated

*return* — whether or not virtual environment is activated

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.has_virtual_env }

### is_active


```lua
function astroui.status.condition.is_active()
  -> boolean
```

 A condition function if the window is currently active

*return* — whether or not the window is currently actie

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_active }

### is_file


```lua
function astroui.status.condition.is_file(bufnr: integer|table)
  -> boolean
```

 A condition function if a buffer is a file

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not the buffer is a file

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_file }

### is_git_repo


```lua
function astroui.status.condition.is_git_repo(bufnr: integer|table)
  -> boolean
```

 A condition function if the current file is in a git repo

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not the current file is in a git repo

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_git_repo }

### is_hlsearch


```lua
function astroui.status.condition.is_hlsearch()
  -> boolean
```

 A condition function if search is visible

*return* — whether or not searching is currently visible

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_hlsearch }

### is_macro_recording


```lua
function astroui.status.condition.is_macro_recording()
  -> boolean
```

 A condition function if a macro is being recorded

*return* — whether or not a macro is currently being recorded

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_macro_recording }

### is_statusline_showcmd


```lua
function astroui.status.condition.is_statusline_showcmd()
  -> boolean
```

 A condition function if showcmdloc is set to statusline

*return* — whether or not statusline showcmd is enabled

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.is_statusline_showcmd }

### lsp_attached


```lua
function astroui.status.condition.lsp_attached(bufnr: integer|table)
  -> boolean
```

 A condition function if LSP is attached

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not LSP is attached

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.lsp_attached }

### numbercolumn_enabled


```lua
function astroui.status.condition.numbercolumn_enabled()
  -> boolean
```

 A condition function if the number column is enabled

*return* — true if vim.opt.number or vim.opt.relativenumber, false if neither

### signcolumn_enabled


```lua
function astroui.status.condition.signcolumn_enabled()
  -> boolean
```

 A condition function if the signcolumn is enabled

*return* — false if vim.opt.signcolumn == "no", true otherwise

### treesitter_available


```lua
function astroui.status.condition.treesitter_available(bufnr: integer|table)
  -> boolean
```

 A condition function if treesitter is in use

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not treesitter is active

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.treesitter_available }


## astroui.status.heirline

AstroNvim Status Heirline Extensions

Statusline related heirline specific extensions

This module can be loaded with `local astro_heirline = require "astroui.status.heirline"`

copyright 2023
license GNU General Public License v3.0

### buffer_picker


```lua
function astroui.status.heirline.buffer_picker(callback: function)
```

 Run the buffer picker and execute the callback function on the selected buffer

*param* `callback` — with a single parameter of the buffer number

### make_buflist


```lua
function astroui.status.heirline.make_buflist(component: table)
  -> table
```

 Make a list of buffers, rendering each buffer with the provided component

### make_tablist


```lua
function astroui.status.heirline.make_tablist(...any)
```

 Alias to require("heirline.utils").make_tablist

### refresh_colors


```lua
function astroui.status.heirline.refresh_colors()
```

 Refresh heirline colors

### tab_type


```lua
function astroui.status.heirline.tab_type(self: table, prefix?: string)
  -> string
```

 A helper function to get the type a tab or buffer is

*param* `self` — the self table from a heirline component function

*param* `prefix` — the prefix of the type, either "tab" or "buffer" (Default: "buffer")

*return* — the string of prefix with the type (i.e. "_active" or "_visible")


## astroui.status.hl

AstroNvim Status Highlighting

Statusline related highlighting utilities

This module can be loaded with `local hl = require "astroui.status.hl"`

copyright 2023
license GNU General Public License v3.0

### file_icon


```lua
function astroui.status.hl.file_icon(name: string)
  -> function
```

 Enable filetype color highlight if enabled in icon_highlights.file_icon options

*param* `name` — the icon_highlights.file_icon table element

*return* — for setting hl property in a component

 @usage local heirline_component = { provider = "Example Provider", hl = require("astroui.status").hl.file_icon("winbar") },

### filetype_color


```lua
function astroui.status.hl.filetype_color(self: astroui.status.hl)
  -> table
```

 Get the foreground color group for the current filetype

*return* — the highlight group for the current filetype foreground

 @usage local heirline_component = { provider = require("astroui.status").provider.fileicon(), hl = require("astroui.status").hl.filetype_color },

### get_attributes


```lua
function astroui.status.hl.get_attributes(name: string, include_bg?: boolean)
  -> table
```

 Merge the color and attributes from user settings for a given name

*param* `name` — the name of the element to get the attributes and colors for

*param* `include_bg` — whether or not to include background color (Default: false)

*return* — a table of highlight information

 @usage local heirline_component = { provider = "Example Provider", hl = require("astroui.status").hl.get_attributes("treesitter") },

### lualine_mode


```lua
function astroui.status.hl.lualine_mode(mode: string, fallback: string)
  -> string
```

 Get the highlight background color of the lualine theme for the current colorscheme

*param* `mode` — the neovim mode to get the color of

*param* `fallback` — the color to fallback on if a lualine theme is not present

*return* — The background color of the lualine theme or the fallback parameter if one doesn't exist

### mode


```lua
function astroui.status.hl.mode()
  -> table
```

 Get the highlight for the current mode

*return* — the highlight group for the current mode

 @usage local heirline_component = { provider = "Example Provider", hl = require("astroui.status").hl.mode },

### mode_bg


```lua
function astroui.status.hl.mode_bg()
  -> string
```


## astroui.status.init

AstroNvim Status Initializers

Statusline related init functions for building dynamic statusline components

This module can be loaded with `local init = require "astroui.status.init"`

copyright 2023
license GNU General Public License v3.0

### breadcrumbs


```lua
function astroui.status.init.breadcrumbs(opts?: table)
  -> function
```

 An `init` function to build a set of children components for LSP breadcrumbs

*param* `opts` — options for configuring the breadcrumbs (default: `{ max_depth = 5, separator = "  ", icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }`)

*return* — The Heirline init function

 @usage local heirline_component = { init = require("astroui.status").init.breadcrumbs { padding = { left = 1 } } }

### separated_path


```lua
function astroui.status.init.separated_path(opts?: table)
  -> function
```

 An `init` function to build a set of children components for a separated path to file

*param* `opts` — options for configuring the breadcrumbs (default: `{ max_depth = 3, path_func = provider.unique_path(), separator = "  ", suffix = true, padding = { left = 0, right = 0 } }`)

*return* — The Heirline init function

 @usage local heirline_component = { init = require("astroui.status").init.separated_path { padding = { left = 1 } } }

### update_events


```lua
function astroui.status.init.update_events(opts: any)
  -> function
```

 An `init` function to build multiple update events which is not supported yet by Heirline's update field

*param* `opts` — an array like table of autocmd events as either just a string or a table with custom patterns and callbacks. TODO: UPDATE TYPE

*return* — The Heirline init function

 @usage local heirline_component = { init = require("astroui.status").init.update_events { "BufEnter", { "User", pattern = "LspProgressUpdate" } } }


## astroui.status.provider

AstroNvim Status Providers

Statusline related provider functions for building statusline components

This module can be loaded with `local provider = require "astroui.status.provider"`

copyright 2023
license GNU General Public License v3.0

### close_button


```lua
function astroui.status.provider.close_button(opts?: table)
  -> string
```

 A provider to simply show a close button icon

*param* `opts` — options passed to the stylize function and the kind of icon to use

*return* — the stylized icon

 @usage local heirline_component = { provider = require("astroui.status").provider.close_button() }
 @see astroui.status.utils.stylize

### diagnostics


```lua
function astroui.status.provider.diagnostics(opts: table)
  -> function|nil
```

 A provider function for showing the current diagnostic count of a specific severity

*param* `opts` — options for severity of diagnostic and options passed to the stylize function

*return* — the function for outputting the diagnostic count

 @usage local heirline_component = { provider = require("astroui.status").provider.diagnostics({ severity = "ERROR" }) }
 @see astroui.status.utils.stylize

### file_encoding


```lua
function astroui.status.provider.file_encoding(opts?: table)
  -> function
```

 A provider function for showing the current file encoding

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the file encoding

 @usage local heirline_component = { provider = require("astroui.status").provider.file_encoding() }
 @see astroui.status.utils.stylize

### file_format


```lua
function astroui.status.provider.file_format(opts?: table)
  -> function
```

 A provider function for showing the current file format

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the file format

 @usage local heirline_component = { provider = require("astroui.status").provider.file_format() }
 @see astroui.status.utils.stylize

### file_icon


```lua
function astroui.status.provider.file_icon(opts?: table)
  -> function
```

 A provider function for showing the current filetype icon

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the filetype icon

 @usage local heirline_component = { provider = require("astroui.status").provider.file_icon() }
 @see astroui.status.utils.stylize

### file_modified


```lua
function astroui.status.provider.file_modified(opts?: table)
  -> function
```

 A provider function for showing if the current file is modifiable

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the indicator if the file is modified

 @usage local heirline_component = { provider = require("astroui.status").provider.file_modified() }
 @see astroui.status.utils.stylize

### file_read_only


```lua
function astroui.status.provider.file_read_only(opts?: table)
  -> function
```

 A provider function for showing if the current file is read-only

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the indicator if the file is read-only

 @usage local heirline_component = { provider = require("astroui.status").provider.file_read_only() }
 @see astroui.status.utils.stylize

### filename


```lua
function astroui.status.provider.filename(opts?: table)
  -> function
```

 A provider function for showing the current filename

*param* `opts` — options for argument to fnamemodify to format filename and options passed to the stylize function

*return* — the function for outputting the filename

 @usage local heirline_component = { provider = require("astroui.status").provider.filename() }
 @see astroui.status.utils.stylize

### filetype


```lua
function astroui.status.provider.filetype(opts?: table)
  -> function
```

 A provider function for showing the current filetype

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the filetype

 @usage local heirline_component = { provider = require("astroui.status").provider.filetype() }
 @see astroui.status.utils.stylize

### fill


```lua
function astroui.status.provider.fill()
  -> string
```

 A provider function for the fill string

*return* — the statusline string for filling the empty space

 @usage local heirline_component = { provider = require("astroui.status").provider.fill }

### foldcolumn


```lua
function astroui.status.provider.foldcolumn(opts?: table)
  -> function
```

 A provider function for building a foldcolumn

*param* `opts` — options passed to the stylize function

*return* — a custom foldcolumn function for the statuscolumn that doesn't show the nest levels

 @usage local heirline_component = { provider = require("astroui.status").provider.foldcolumn }
 @see astroui.status.utils.stylize

### git_branch


```lua
function astroui.status.provider.git_branch(opts: table)
  -> function
```

 A provider function for showing the current git branch

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the git branch

 @usage local heirline_component = { provider = require("astroui.status").provider.git_branch() }
 @see astroui.status.utils.stylize

### git_diff


```lua
function astroui.status.provider.git_diff(opts?: table)
  -> function|nil
```

 A provider function for showing the current git diff count of a specific type

*param* `opts` — options for type of git diff and options passed to the stylize function

*return* — the function for outputting the git diff

 @usage local heirline_component = { provider = require("astroui.status").provider.git_diff({ type = "added" }) }
 @see astroui.status.utils.stylize

### lsp_client_names


```lua
function astroui.status.provider.lsp_client_names(opts?: table)
  -> function
```

 A provider function for showing the connected LSP client names

*param* `opts` — options for explanding null_ls clients, max width percentage, and options passed to the stylize function

*return* — the function for outputting the LSP client names

 @usage local heirline_component = { provider = require("astroui.status").provider.lsp_client_names({ integrations = { null_ls = true, conform = true, lint = true }, truncate = 0.25 }) }
 @see astroui.status.utils.stylize

### lsp_progress


```lua
function astroui.status.provider.lsp_progress(opts?: table)
  -> function
```

 A provider function for showing the current progress of loading language servers

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the LSP progress

 @usage local heirline_component = { provider = require("astroui.status").provider.lsp_progress() }
 @see astroui.status.utils.stylize

### macro_recording


```lua
function astroui.status.provider.macro_recording(opts?: table)
  -> function
```

 A provider function for displaying if a macro is currently being recorded

*param* `opts` — a prefix before the recording register and options passed to the stylize function

*return* — a function that returns a string of the current recording status

 @usage local heirline_component = { provider = require("astroui.status").provider.macro_recording() }
 @see astroui.status.utils.stylize

### mode_text


```lua
function astroui.status.provider.mode_text(opts?: table)
  -> function
```

 A provider function for showing the text of the current vim mode

*param* `opts` — options for padding the text and options passed to the stylize function

*return* — the function for displaying the text of the current vim mode

 @usage local heirline_component = { provider = require("astroui.status").provider.mode_text() }
 @see astroui.status.utils.stylize

### numbercolumn


```lua
function astroui.status.provider.numbercolumn(opts?: table)
  -> function
```

 A provider function for the numbercolumn string

*param* `opts` — options passed to the stylize function

*return* — the statuscolumn string for adding the numbercolumn

 @usage local heirline_component = { provider = require("astroui.status").provider.numbercolumn }
 @see astroui.status.utils.stylize

### paste


```lua
function astroui.status.provider.paste(opts?: table)
  -> function
```

 A provider function for showing if paste is enabled

*param* `opts` — options passed to the stylize function

*return* — the function for outputting if paste is enabled

 @usage local heirline_component = { provider = require("astroui.status").provider.paste() }
 @see astroui.status.utils.stylize

### percentage


```lua
function astroui.status.provider.percentage(opts?: table)
  -> function
```

 A provider function for showing the percentage of the current location in a document

*param* `opts` — options for Top/Bot text, fixed width, and options passed to the stylize function

*return* — the statusline string for displaying the percentage of current document location

 @usage local heirline_component = { provider = require("astroui.status").provider.percentage() }
 @see astroui.status.utils.stylize

### ruler


```lua
function astroui.status.provider.ruler(opts?: table)
  -> function
```

 A provider function for showing the current line and character in a document

*param* `opts` — options for padding the line and character locations and options passed to the stylize function

*return* — the statusline string for showing location in document line_num:char_num

 @usage local heirline_component = { provider = require("astroui.status").provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
 @see astroui.status.utils.stylize

### scrollbar


```lua
function astroui.status.provider.scrollbar(opts?: table)
  -> function
```

 A provider function for showing the current location as a scrollbar

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the scrollbar

 @usage local heirline_component = { provider = require("astroui.status").provider.scrollbar() }
 @see astroui.status.utils.stylize

### search_count


```lua
function astroui.status.provider.search_count(opts?: table)
  -> function
```

 A provider function for displaying the current search count

*param* `opts` — options for `vim.fn.searchcount` and options passed to the stylize function

*return* — a function that returns a string of the current search location

 @usage local heirline_component = { provider = require("astroui.status").provider.search_count() }
 @see astroui.status.utils.stylize

### showcmd


```lua
function astroui.status.provider.showcmd(opts?: table)
  -> string
```

 A provider function for displaying the current command

*param* `opts` — of options passed to the stylize function

*return* — the statusline string for showing the current command

 @usage local heirline_component = { provider = require("astroui.status").provider.showcmd() }
 @see astroui.status.utils.stylize

### signcolumn


```lua
function astroui.status.provider.signcolumn(opts?: table)
  -> string
```

 A provider function for the signcolumn string

*param* `opts` — options passed to the stylize function

*return* — the statuscolumn string for adding the signcolumn

 @usage local heirline_component = { provider = require("astroui.status").provider.signcolumn }
 @see astroui.status.utils.stylize

### spell


```lua
function astroui.status.provider.spell(opts?: table)
  -> function
```

 A provider function for showing if spellcheck is on

*param* `opts` — options passed to the stylize function

*return* — the function for outputting if spell is enabled

 @usage local heirline_component = { provider = require("astroui.status").provider.spell() }
 @see astroui.status.utils.stylize

### str


```lua
function astroui.status.provider.str(opts?: table)
  -> string
```

 A provider function for displaying a single string

*param* `opts` — options passed to the stylize function

*return* — the stylized statusline string

 @usage local heirline_component = { provider = require("astroui.status").provider.str({ str = "Hello" }) }
 @see astroui.status.utils.stylize

### tabnr


```lua
function astroui.status.provider.tabnr()
  -> function
```

 A provider function for the current tab numbre

*return* — the statusline function to return a string for a tab number

 @usage local heirline_component = { provider = require("astroui.status").provider.tabnr() }

### treesitter_status


```lua
function astroui.status.provider.treesitter_status(opts?: table)
  -> function
```

 A provider function for showing if treesitter is connected

*param* `opts` — options passed to the stylize function

*return* — function for outputting TS if treesitter is connected

 @usage local heirline_component = { provider = require("astroui.status").provider.treesitter_status() }
 @see astroui.status.utils.stylize

### unique_path


```lua
function astroui.status.provider.unique_path(opts?: table)
  -> function
```

 Get a unique filepath between all buffers

*param* `opts` — options for function to get the buffer name, a buffer number, max length, and options passed to the stylize function

*return* — path to file that uniquely identifies each buffer

 @usage local heirline_component = { provider = require("astroui.status").provider.unique_path() }
 @see astroui.status.utils.stylize

### virtual_env


```lua
function astroui.status.provider.virtual_env(opts: table)
  -> function
```

 A provider function for showing the current virtual environment name

*param* `opts` — options passed to the stylize function

*return* — the function for outputting the virtual environment

 @usage local heirline_component = { provider = require("astroui.status").provider.virtual_env() }
 @see astroui.status.utils.stylize


## astroui.status.utils

AstroNvim Status Utilities

Statusline related uitility functions

This module can be loaded with `local status_utils = require "astroui.status.utils"`

copyright 2023
license GNU General Public License v3.0

### build_provider


```lua
function astroui.status.utils.build_provider(opts?: table, provider?: string|function, _: any)
  -> table|false
```

 Convert a component parameter table to a table that can be used with the component builder

*param* `opts` — a table of provider options

*param* `provider` — a provider in `M.providers`

*return* — the provider table that can be used in `M.component.builder`

```lua
return #1:
    | false
```

### decode_pos


```lua
function astroui.status.utils.decode_pos(c: integer)
  -> line: integer
  2. column: integer
  3. window: integer
```

 Decode a previously encoded position to it's sub parts

*param* `c` — the encoded position

### encode_pos


```lua
function astroui.status.utils.encode_pos(line: integer, col: integer, winnr: integer)
  -> the: integer
```

 Encode a position to a single value that can be decoded later

*param* `line` — line number of position

*param* `col` — column number of position

*param* `winnr` — a window number

*return* `the` — encoded position

### null_ls_providers


```lua
function astroui.status.utils.null_ls_providers(filetype: string)
  -> table
```

 Get a list of registered null-ls providers for a given filetype

*param* `filetype` — the filetype to search null-ls for

*return* — a table of null-ls sources

### null_ls_sources


```lua
function astroui.status.utils.null_ls_sources(filetype: string, method: string)
  -> string[]
```

 Get the null-ls sources for a given null-ls method

*param* `filetype` — the filetype to search null-ls for

*param* `method` — the null-ls method (check null-ls documentation for available methods)

*return* — the available sources for the given filetype and method

### pad_string


```lua
function astroui.status.utils.pad_string(str: string, padding: table)
  -> string
```

 Add left and/or right padding to a string

*param* `str` — the string to add padding to

*param* `padding` — a table of the format `{ left = 0, right = 0}` that defines the number of spaces to include to the left and the right of the string

*return* — the padded string

### setup_providers


```lua
function astroui.status.utils.setup_providers(opts: table, providers: string[], setup?: function)
  -> table
```

 Convert key/value table of options to an array of providers for the component builder

*param* `opts` — the table of options for the components

*param* `providers` — an ordered list like array of providers that are configured in the options table

*param* `setup` — a function that takes provider options table, provider name, provider index and returns the setup provider table, optional, default is `M.build_provider`

*return* — the fully setup options table with the appropriately ordered providers

### statuscolumn_clickargs


```lua
function astroui.status.utils.statuscolumn_clickargs(self: any, minwid: any, clicks: any, button: any, mods: any)
  -> table
```

 A helper function for decoding statuscolumn click events with mouse click pressed, modifier keys, as well as which signcolumn sign was clicked if any

*param* `self` — the self parameter from Heirline component on_click.callback function call

*param* `minwid` — the minwid parameter from Heirline component on_click.callback function call

*param* `clicks` — the clicks parameter from Heirline component on_click.callback function call

*param* `button` — the button parameter from Heirline component on_click.callback function call

*param* `mods` — the button parameter from Heirline component on_click.callback function call

*return* — the argument table with the decoded mouse information and signcolumn signs information

 @usage local heirline_component = { on_click = { callback = function(...) local args = require("astroui.status").utils.statuscolumn_clickargs(...) end } }

### stylize


```lua
function astroui.status.utils.stylize(str?: string, opts?: table)
  -> string
```

 A utility function to stylize a string with an icon from lspkind, separators, and left/right padding

*param* `str` — the string to stylize

*param* `opts` — options of `{ padding = { left = 0, right = 0 }, separator = { left = "|", right = "|" }, escape = true, show_empty = false, icon = { kind = "NONE", padding = { left = 0, right = 0 } } }`

*return* — the stylized string

 @usage local string = require("astroui.status").utils.stylize("Hello", { padding = { left = 1, right = 1 }, icon = { kind = "String" } })

### surround


```lua
function astroui.status.utils.surround(separator: string|string[], color: string|function|table, component: table, condition: boolean|function, update?: any)
  -> table
```

 Surround component with separator and color adjustment

*param* `separator` — the separator index to use in the `separators` table

*param* `color` — the color to use as the separator foreground/component background

*param* `component` — the component to surround

*param* `condition` — the condition for displaying the surrounded component

*param* `update` — the condition for displaying the surrounded component

*return* — the new surrounded component

### width


```lua
function astroui.status.utils.width(is_winbar?: boolean)
  -> integer
```

 A utility function to get the width of the bar

*param* `is_winbar` — true if you want the width of the winbar, false if you want the statusline width

*return* — the width of the specified bar


