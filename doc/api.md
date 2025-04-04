# Lua API

astroui API documentation

## astroui

### config


```lua
AstroUIOpts
```

### get_hlgroup


```lua
function astroui.get_hlgroup(name: string, fallback?: table)
  -> properties: table
```

 Get highlight properties for a given highlight name

*param* `name` — The highlight group name

*param* `fallback` — The fallback highlight properties

*return* `properties` — the highlight group properties

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

### set_colorscheme


```lua
function astroui.set_colorscheme()
```

 Set the configured colorscheme

### setup


```lua
function astroui.setup(opts: AstroUIOpts)
```

 Setup and configure AstroUI


## astroui.status.component

### breadcrumbs


```lua
function astroui.status.component.breadcrumbs(opts?: AstroUIComponentBreadcrumbsOpts)
  -> table
```

 A function to build a set of children components for an LSP breadcrumbs section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.breadcrumbs()

### builder


```lua
function astroui.status.component.builder(opts?: AstroUIComponentBuilderOpts)
  -> table
```

 A general function to build a section of astronvim status providers with highlights, conditions, and section surrounding

*param* `opts` — component builder options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").components.builder({ { provider = "file_icon", opts = { padding = { right = 1 } } }, { provider = "filename" } })

### cmd_info


```lua
function astroui.status.component.cmd_info(opts?: AstroUIComponentCmdInfoOpts)
  -> table
```

 A function to build a set of children components for information shown in the cmdline

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.cmd_info()

### diagnostics


```lua
function astroui.status.component.diagnostics(opts?: AstroUIComponentDiagnosticsOpts)
  -> table
```

 A function to build a set of children components for a diagnostics section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.diagnostics()

### file_info


```lua
function astroui.status.component.file_info(opts?: AstroUIComponentFileInfoOpts)
  -> table
```

 A function to build a set of children components for an entire file information section

*param* `opts` — provider options

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
function astroui.status.component.foldcolumn(opts?: AstroUIComponentFoldcolumnOpts)
  -> table
```

 A function to build a set of components for a foldcolumn section in a statuscolumn

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.foldcolumn()

### git_branch


```lua
function astroui.status.component.git_branch(opts?: AstroUIComponentGitBranchOpts)
  -> table
```

 A function to build a set of children components for a git branch section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.git_branch()

### git_diff


```lua
function astroui.status.component.git_diff(opts?: AstroUIComponentGitDiffOpts)
  -> table
```

 A function to build a set of children components for a git difference section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.git_diff()

### lsp


```lua
function astroui.status.component.lsp(opts?: AstroUIComponentLspOpts)
  -> table
```

 A function to build a set of children components for an LSP section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.lsp()

### mode


```lua
function astroui.status.component.mode(opts?: AstroUIComponentModeOpts)
  -> table
```

 A function to build a set of children components for a mode section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.mode { mode_text = true }

### nav


```lua
function astroui.status.component.nav(opts?: AstroUIComponentNavOpts)
  -> table
```

 A function to build a set of children components for an entire navigation section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.nav()

### numbercolumn


```lua
function astroui.status.component.numbercolumn(opts?: AstroUIComponentNumbercolumnOpts)
  -> table
```

 A function to build a set of components for a numbercolumn section in statuscolumn

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.numbercolumn()

### separated_path


```lua
function astroui.status.component.separated_path(opts?: AstroUIComponentSeparatedPathOpts)
  -> table
```

 A function to build a set of children components for the current file path

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.separated_path()

### signcolumn


```lua
function astroui.status.component.signcolumn(opts?: AstroUIComponentSigncolumnOpts)
  -> table
```

 A function to build a set of components for a signcolumn section in statuscolumn

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.signcolumn()

### tabline_file_info


```lua
function astroui.status.component.tabline_file_info(opts?: AstroUIComponentTablineFileInfoOpts)
  -> table
```

 A function with different file_info defaults specifically for use in the tabline

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.tabline_file_info()

### treesitter


```lua
function astroui.status.component.treesitter(opts?: AstroUIComponentTreesitterOpts)
  -> table
```

 A function to build a set of children components for a Treesitter section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.treesitter()

### virtual_env


```lua
function astroui.status.component.virtual_env(opts?: AstroUIComponentVirtualEnvOpts)
  -> table
```

 A function to build a set of children components for a git branch section

*param* `opts` — provider options

*return* — The Heirline component table

 @usage local heirline_component = require("astroui.status").component.git_branch()


## astroui.status.condition

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

*return* — whether or not the buffer filetype,buftype,bufname match a pattern

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

*return* — whether or not the window is currently active

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

 A condition function if a treesitter parser for a given buffer is available

*param* `bufnr` — a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer

*return* — whether or not treesitter is active

 @usage local heirline_component = { provider = "Example Provider", condition = require("astroui.status").condition.treesitter_available }


## astroui.status.heirline

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
function astroui.status.hl.filetype_color(self?: { bufnr: integer })
  -> table
```

 Get the foreground color group for the current filetype

*param* `self` — component state that may hold the buffer number

*return* — the highlight group for the current filetype foreground

 @usage local heirline_component = { provider = require("astroui.status").provider.fileicon(), hl = require("astroui.status").hl.filetype_color },

### get_attributes


```lua
function astroui.status.hl.get_attributes(name: string, include_bg?: boolean)
  -> table
```

 Merge the color and attributes from user settings for a given name

*param* `name` — , the name of the element to get the attributes and colors for

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

### breadcrumbs


```lua
function astroui.status.init.breadcrumbs(opts?: AstroUIInitBreadcrumbsOpts)
  -> function
```

 An `init` function to build a set of children components for LSP breadcrumbs

*param* `opts` — component init options

*return* — The Heirline init function

 @usage local heirline_component = { init = require("astroui.status").init.breadcrumbs { padding = { left = 1 } } }

### separated_path


```lua
function astroui.status.init.separated_path(opts?: AstroUIInitSeparatedPathOpts)
  -> function
```

 An `init` function to build a set of children components for a separated path to file

*param* `opts` — component init options

*return* — The Heirline init function

 @usage local heirline_component = { init = require("astroui.status").init.separated_path { padding = { left = 1 } } }

### update_events


```lua
function astroui.status.init.update_events(opts: AstroUIUpdateEvent|AstroUIUpdateEvent[])
  -> function
```

 An `init` function to build multiple update events which is not supported yet by Heirline's update field

*param* `opts` — an array like table of autocmd events as either just a string or a table with custom patterns and callbacks. TODO: UPDATE TYPE

*return* — The Heirline init function

 @usage local heirline_component = { init = require("astroui.status").init.update_events { "BufEnter", { "User", pattern = "LspProgressUpdate" } } }


## astroui.status.provider

### bufnr


```lua
function astroui.status.provider.bufnr(opts?: AstroUIProviderBufnrOpts)
  -> function
```

 A provider function for showing the buffer number

*param* `opts` — provider options

*return* — the function for outputting the buffer number

 @usage local heirline_component = { provider = require("astroui.status").provider.bufnr() }
 @see astroui.status.utils.stylize

### close_button


```lua
function astroui.status.provider.close_button(opts?: AstroUIProviderCloseButtonOpts)
  -> string
```

 A provider to simply show a close button icon

*param* `opts` — provider options

*return* — the stylized icon

 @usage local heirline_component = { provider = require("astroui.status").provider.close_button() }
 @see astroui.status.utils.stylize

### diagnostics


```lua
function astroui.status.provider.diagnostics(opts?: AstroUIProviderDiagnosticsOpts)
  -> function|nil
```

 A provider function for showing the current diagnostic count of a specific severity

*param* `opts` — provider options

*return* — the function for outputting the diagnostic count

 @usage local heirline_component = { provider = require("astroui.status").provider.diagnostics({ severity = "ERROR" }) }
 @see astroui.status.utils.stylize

### file_encoding


```lua
function astroui.status.provider.file_encoding(opts?: AstroUIProviderFileEncodingOpts)
  -> function
```

 A provider function for showing the current file encoding

*param* `opts` — provider options

*return* — the function for outputting the file encoding

 @usage local heirline_component = { provider = require("astroui.status").provider.file_encoding() }
 @see astroui.status.utils.stylize

### file_format


```lua
function astroui.status.provider.file_format(opts?: AstroUIProviderFileFormatOpts)
  -> function
```

 A provider function for showing the current file format

*param* `opts` — provider options

*return* — the function for outputting the file format

 @usage local heirline_component = { provider = require("astroui.status").provider.file_format() }
 @see astroui.status.utils.stylize

### file_icon


```lua
function astroui.status.provider.file_icon(opts?: AstroUIProviderFileIconOpts)
  -> function
```

 A provider function for showing the current filetype icon

*param* `opts` — provider options

*return* — the function for outputting the filetype icon

 @usage local heirline_component = { provider = require("astroui.status").provider.file_icon() }
 @see astroui.status.utils.stylize

### file_modified


```lua
function astroui.status.provider.file_modified(opts?: AstroUIProviderFileModifiedOpts)
  -> function
```

 A provider function for showing if the current file is modifiable

*param* `opts` — provider options

*return* — the function for outputting the indicator if the file is modified

 @usage local heirline_component = { provider = require("astroui.status").provider.file_modified() }
 @see astroui.status.utils.stylize

### file_read_only


```lua
function astroui.status.provider.file_read_only(opts?: AstroUIProviderFileReadOnlyOpts)
  -> function
```

 A provider function for showing if the current file is read-only

*param* `opts` — provider options

*return* — the function for outputting the indicator if the file is read-only

 @usage local heirline_component = { provider = require("astroui.status").provider.file_read_only() }
 @see astroui.status.utils.stylize

### filename


```lua
function astroui.status.provider.filename(opts?: AstroUIProviderFilenameOpts)
  -> function
```

 A provider function for showing the current filename

*param* `opts` — provider options

*return* — the function for outputting the filename

 @usage local heirline_component = { provider = require("astroui.status").provider.filename() }
 @see astroui.status.utils.stylize

### filetype


```lua
function astroui.status.provider.filetype(opts?: AstroUIProviderFiletypeOpts)
  -> function
```

 A provider function for showing the current filetype

*param* `opts` — provider options

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
function astroui.status.provider.foldcolumn(opts?: AstroUIProviderFoldcolumnOpts)
  -> function
```

 A provider function for building a foldcolumn

*param* `opts` — provider options

*return* — a custom foldcolumn function for the statuscolumn that doesn't show the nest levels

 @usage local heirline_component = { provider = require("astroui.status").provider.foldcolumn }
 @see astroui.status.utils.stylize

### git_branch


```lua
function astroui.status.provider.git_branch(opts?: AstroUIProviderGitBranchOpts)
  -> function
```

 A provider function for showing the current git branch

*param* `opts` — provider options

*return* — the function for outputting the git branch

 @usage local heirline_component = { provider = require("astroui.status").provider.git_branch() }
 @see astroui.status.utils.stylize

### git_diff


```lua
function astroui.status.provider.git_diff(opts?: AstroUIProviderGitDiffOpts)
  -> function|nil
```

 A provider function for showing the current git diff count of a specific type

*param* `opts` — provider options

*return* — the function for outputting the git diff

 @usage local heirline_component = { provider = require("astroui.status").provider.git_diff({ type = "added" }) }
 @see astroui.status.utils.stylize

### lsp_client_names


```lua
function astroui.status.provider.lsp_client_names(opts?: AstroUIProviderLspClientNamesOpts)
  -> function
```

 A provider function for showing the connected LSP client names

*param* `opts` — provider options

*return* — the function for outputting the LSP client names

 @usage local heirline_component = { provider = require("astroui.status").provider.lsp_client_names({ integrations = { null_ls = true, conform = true, lint = true }, truncate = 0.25 }) }
 @see astroui.status.utils.stylize

### lsp_progress


```lua
function astroui.status.provider.lsp_progress(opts?: AstroUIProviderLspProgressOpts)
  -> function
```

 A provider function for showing the current progress of loading language servers

*param* `opts` — provider options

*return* — the function for outputting the LSP progress

 @usage local heirline_component = { provider = require("astroui.status").provider.lsp_progress() }
 @see astroui.status.utils.stylize

### macro_recording


```lua
function astroui.status.provider.macro_recording(opts?: AstroUIProviderMacroRecordingOpts)
  -> function
```

 A provider function for displaying if a macro is currently being recorded

*param* `opts` — provider options

*return* — a function that returns a string of the current recording status

 @usage local heirline_component = { provider = require("astroui.status").provider.macro_recording() }
 @see astroui.status.utils.stylize

### mode_text


```lua
function astroui.status.provider.mode_text(opts?: AstroUIProviderModeTextOpts)
  -> function
```

 A provider function for showing the text of the current vim mode

*param* `opts` — provider options

*return* — the function for displaying the text of the current vim mode

 @usage local heirline_component = { provider = require("astroui.status").provider.mode_text() }
 @see astroui.status.utils.stylize

### numbercolumn


```lua
function astroui.status.provider.numbercolumn(opts?: AstroUIProviderNumbercolumnOpts)
  -> function
```

 A provider function for the numbercolumn string

*param* `opts` — provider options

*return* — the statuscolumn string for adding the numbercolumn

 @usage local heirline_component = { provider = require("astroui.status").provider.numbercolumn }
 @see astroui.status.utils.stylize

### paste


```lua
function astroui.status.provider.paste(opts?: AstroUIProviderPasteOpts)
  -> function
```

 A provider function for showing if paste is enabled

*param* `opts` — provider options

*return* — the function for outputting if paste is enabled

 @usage local heirline_component = { provider = require("astroui.status").provider.paste() }
 @see astroui.status.utils.stylize

### percentage


```lua
function astroui.status.provider.percentage(opts?: AstroUIProviderPercentageOpts)
  -> function
```

 A provider function for showing the percentage of the current location in a document

*param* `opts` — provider options

*return* — the statusline string for displaying the percentage of current document location

 @usage local heirline_component = { provider = require("astroui.status").provider.percentage() }
 @see astroui.status.utils.stylize

### ruler


```lua
function astroui.status.provider.ruler(opts?: AstroUIProviderRulerOpts)
  -> function
```

 A provider function for showing the current line and character in a document

*param* `opts` — provider options

*return* — the statusline string for showing location in document line_num:char_num

 @usage local heirline_component = { provider = require("astroui.status").provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
 @see astroui.status.utils.stylize

### scrollbar


```lua
function astroui.status.provider.scrollbar(opts?: AstroUIProviderScrollbarOpts)
  -> function
```

 A provider function for showing the current location as a scrollbar

*param* `opts` — provider options

*return* — the function for outputting the scrollbar

 @usage local heirline_component = { provider = require("astroui.status").provider.scrollbar() }
 @see astroui.status.utils.stylize

### search_count


```lua
function astroui.status.provider.search_count(opts?: AstroUIProviderSearchCountOpts)
  -> function
```

 A provider function for displaying the current search count

*param* `opts` — provider options

*return* — a function that returns a string of the current search location

 @usage local heirline_component = { provider = require("astroui.status").provider.search_count() }
 @see astroui.status.utils.stylize

### showcmd


```lua
function astroui.status.provider.showcmd(opts?: AstroUIProviderShowcmdOpts)
  -> string
```

 A provider function for displaying the current command

*param* `opts` — provider options

*return* — the statusline string for showing the current command

 @usage local heirline_component = { provider = require("astroui.status").provider.showcmd() }
 @see astroui.status.utils.stylize

### signcolumn


```lua
function astroui.status.provider.signcolumn(opts?: AstroUIProviderSigncolumnOpts)
  -> string
```

 A provider function for the signcolumn string

*param* `opts` — provider options

*return* — the statuscolumn string for adding the signcolumn

 @usage local heirline_component = { provider = require("astroui.status").provider.signcolumn }
 @see astroui.status.utils.stylize

### spell


```lua
function astroui.status.provider.spell(opts?: AstroUIProviderSpellOpts)
  -> function
```

 A provider function for showing if spellcheck is on

*param* `opts` — provider options

*return* — the function for outputting if spell is enabled

 @usage local heirline_component = { provider = require("astroui.status").provider.spell() }
 @see astroui.status.utils.stylize

### str


```lua
function astroui.status.provider.str(opts?: AstroUIProviderStrOpts)
  -> string
```

 A provider function for displaying a single string

*param* `opts` — provider options

*return* — the stylized statusline string

 @usage local heirline_component = { provider = require("astroui.status").provider.str({ str = "Hello" }) }
 @see astroui.status.utils.stylize

### tabnr


```lua
function astroui.status.provider.tabnr()
  -> function
```

 A provider function for the current tab number

*return* — the statusline function to return a string for a tab number

 @usage local heirline_component = { provider = require("astroui.status").provider.tabnr() }

### treesitter_status


```lua
function astroui.status.provider.treesitter_status(opts?: AstroUIProviderTreesitterStatusOpts)
  -> function
```

 A provider function for showing if treesitter is connected

*param* `opts` — provider options

*return* — function for outputting TS if treesitter is connected

 @usage local heirline_component = { provider = require("astroui.status").provider.treesitter_status() }
 @see astroui.status.utils.stylize

### unique_path


```lua
function astroui.status.provider.unique_path(opts?: AstroUIProviderUniquePathOpts)
  -> function
```

 Get a unique filepath between all buffers

*param* `opts` — provider options

*return* — path to file that uniquely identifies each buffer

 @usage local heirline_component = { provider = require("astroui.status").provider.unique_path() }
 @see astroui.status.utils.stylize

### virtual_env


```lua
function astroui.status.provider.virtual_env(opts?: AstroUIProviderVirtualEnvOpts)
  -> function
```

 A provider function for showing the current virtual environment name

*param* `opts` — provider options

*return* — the function for outputting the virtual environment

 @usage local heirline_component = { provider = require("astroui.status").provider.virtual_env() }
 @see astroui.status.utils.stylize


## astroui.status.utils

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

### icon_provider


```lua
function astroui.status.utils.icon_provider(bufnr: integer)
  -> icon: string?
  2. color: string?
```

 Resolve the icon and color information for a given buffer

*param* `bufnr` — the buffer number to resolve the icon and color of

*return* `icon` — the icon string

*return* `color` — the hex color of the icon

### null_ls_providers


```lua
function astroui.status.utils.null_ls_providers(params: table)
  -> table
```

 Get a list of registered null-ls providers for a given filetype

*param* `params` — parameters to use for null-ls providers

*return* — a table of null-ls sources

### null_ls_sources


```lua
function astroui.status.utils.null_ls_sources(params: table)
  -> string[]
```

 Get the null-ls sources for a given null-ls method

*param* `params` — parameters to use for checking null-ls sources

*return* — the available sources for the given filetype and method

### pad_string


```lua
function astroui.status.utils.pad_string(str: string, padding: AstroUIStatusPadding)
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
function astroui.status.utils.stylize(str?: string, opts?: AstroUIStatusStylizeOpts)
  -> string
```

 A utility function to stylize a string with an icon from lspkind, separators, and left/right padding

*param* `str` — the string to stylize

*param* `opts` — options for stylizing the string

*return* — the stylized string

 @usage local string = require("astroui.status").utils.stylize("Hello", { padding = { left = 1, right = 1 }, icon = { kind = "String" } })

### surround


```lua
function astroui.status.utils.surround(separator: string|string[], color: string|function|table, component: table, condition: boolean|function, update?: AstroUIUpdateEvent|AstroUIUpdateEvent[])
  -> table
```

 Surround component with separator and color adjustment

*param* `separator` — the separator index to use in the `separators` table

*param* `color` — the color to use as the separator foreground/component background

*param* `component` — the component to surround

*param* `condition` — the condition for displaying the surrounded component

*param* `update` — control updating of separators, either a list of events or true to update freely

*return* — the new surrounded component

### width


```lua
function astroui.status.utils.width(is_winbar?: boolean)
  -> integer
```

 A utility function to get the width of the bar

*param* `is_winbar` — true if you want the width of the winbar, false if you want the statusline width

*return* — the width of the specified bar


