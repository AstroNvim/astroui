# 🎨 AstroUI

AstroUI provides a simple API for configuring and setting up the user interface in [AstroNvim](https://github.com/AstroNvim/AstroNvim).

## ✨ Features

- Unified interface for configuring icons (with and without Nerd Fonts)
- Easily modify highlight groups of any and all colorschemes
- An extensive `status` API for building custom status lines (Relies on [`astrocore`][astrocore])

## ⚡️ Requirements

- Neovim >= 0.9
- [astrocore][astrocore] (_optional_)

## 📦 Installation

Install the plugin with your plugin manager of choice:

[**lazy.nvim**][lazy]

```lua
{
  "AstroNvim/astroui",
  lazy = false, -- disable lazy loading
  priority = 10000, -- load AstroUI first
  opts = {
    -- set configuration options  as described below
  }
}
```

[**packer.nvim**](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "AstroNvim/astroui",
})

require("astroui").setup({
  -- set configuration options  as described below
})
```

## ⚙️ Configuration

**AstroUI** comes with the no defaults, but can be configured fully through the `opts` table in lazy or through calling `require("astroui").setup({})`. Here are descriptions of the options and some example usages:

```lua
---@type AstroUIConfig
{
  -- Colorscheme set on startup, a string that is used with `:colorscheme astrodark`
  colorscheme = "astrodark",
  -- Override highlights in any colorscheme
  -- Keys can be:
  --   `init`: table of highlights to apply to all colorschemes
  --   `<colorscheme_name>` override highlights in the colorscheme with name: `<colorscheme_name>`
  highlights = {
    -- this table overrides highlights in all colorschemes
    init = {
      Normal = { bg = "#000000" },
    },
    -- a table of overrides/changes when applying astrotheme
    astrotheme = {
      Normal = { bg = "#000000" },
    },
  },
  -- A table of icons in the UI using NERD fonts
  icons = {
    GitAdd = "",
  },
  -- A table of only text "icons" used when icons are disabled
  text_icons = {
    GitAdd = "[+]",
  },
  -- Configuration options for the AstroNvim lines and bars built with the `status` API.
  status = {
    -- Configure attributes of components defined in the `status` API. Check the AstroNvim documentation for a complete list of color names, this applies to colors that have `_fg` and/or `_bg` names with the suffix removed (ex. `git_branch_fg` as attributes from `git_branch`).
    attributes = {
      git_branch = { bold = true },
    },
    -- Configure colors of components defined in the `status` API. Check the AstroNvim documentation for a complete list of color names.
    colors = {
      git_branch_fg = "#ABCDEF",
    },
    -- Configure which icons that are highlighted based on context
    icon_highlights = {
      -- enable or disable breadcrumb icon highlighting
      breadcrumbs = false,
      -- Enable or disable the highlighting of filetype icons both in the statusline and tabline
      file_icon = {
        tabline = function(self) return self.is_active or self.is_visible end,
        statusline = true,
      },
    },
    -- Configure characters used as separators for various elements
    separators = {
      none = { "", "" },
      left = { "", "  " },
      right = { "  ", "" },
      center = { "  ", "  " },
      tab = { "", "" },
      breadcrumbs = "  ",
      path = "  ",
    },
    -- Configure enabling/disabling of winbar
    winbar = {
      enabled = { -- whitelist buffer patterns
        filetype = { "gitsigns.blame" },
      },
      disabled = { -- blacklist buffer patterns
        buftype = { "nofile", "terminal" },
      },
    },
  },
  -- Configure theming of Lazygit, set to `false` to disable
  lazygit = {
    theme_path = vim.fs.normalize(vim.fn.stdpath "cache" .. "/lazygit-theme.yml"),
    theme = {
      [241] = { fg = "Special" },
      activeBorderColor = { fg = "MatchParen", bold = true },
      cherryPickedCommitBgColor = { fg = "Identifier" },
      cherryPickedCommitFgColor = { fg = "Function" },
      defaultFgColor = { fg = "Normal" },
      inactiveBorderColor = { fg = "FloatBorder" },
      optionsTextColor = { fg = "Function" },
      searchingActiveBorderColor = { fg = "MatchParen", bold = true },
      selectedLineBgColor = { bg = "Visual" },
      unstagedChangesColor = { fg = "DiagnosticError" },
    },
  },
}
```

## 📦 API

**AstroUI** provides a Lua API with utility functions. This can be viewed with `:h astroui` or in the repository at [doc/api.md](doc/api.md)

## 🚀 Contributing

If you plan to contribute, please check the [contribution guidelines](https://github.com/AstroNvim/.github/blob/main/CONTRIBUTING.md) first.

[astrocore]: https://github.com/AstroNvim/astrocore
[lazy]: https://github.com/folke/lazy.nvim
