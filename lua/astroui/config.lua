--- ### AstroNvim UI Configuration
--
-- This module simply defines the configuration table structure for `opts` used in:
--
--    require("astroui").setup(opts)
--
-- @module astroui.config
-- @copyright 2023
-- @license GNU General Public License v3.0

---@type AstroUIConfig
return {
  --- Colorscheme set on startup
  -- @usage colorscheme = "astrodark"
  colorscheme = nil,
  --- Override highlights in any colorscheme
  -- @field init table of highlights to apply to all colorschemes
  -- @field colorscheme_name override highlights in the colorscheme with name: `colorscheme_name`
  -- @usage highlights = {
  --      -- this table overrides highlights in all colorschemes
  --      init = {
  --        Normal = { bg = "#000000" },
  --      },
  --      -- a table of overrides/changes when applying astrotheme
  --      astrotheme = {
  --        Normal = { bg = "#000000" },
  --      },
  -- }
  highlights = {},
  --- A table of icons in the UI using NERD fonts
  -- @usage icons = {
  --   GitAdd = "",
  -- }
  icons = {},
  --- A table of only text "icons" used when icons are disabled
  -- @usage text_icons = {
  --   GitAdd = "[+]",
  -- }
  text_icons = {},
  status = {
    attributes = {},
    buf_matchers = {},
    colors = {},
    fallback_colors = {},
    icon_highlights = {},
    modes = {},
    separators = {},
    setup_colors = nil,
    sign_handlers = {},
  },
}
