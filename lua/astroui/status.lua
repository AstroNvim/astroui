--- ### AstroNvim Status Utilities
--
-- Status utility functions to use within AstroNvim and user configurations.
--
-- This module can be loaded with `local astro = require "astroui.status"`
--
-- @module astroui.status
-- @see astroui
-- @copyright 2023
-- @license GNU General Public License v3.0

return {
  --- @see astroui.status.component
  component = require "astroui.status.component",
  --- @see astroui.status.condition
  condition = require "astroui.status.condition",
  --- @see astroui.status.heirline
  heirline = require "astroui.status.heirline",
  --- @see astroui.status.hl
  hl = require "astroui.status.hl",
  --- @see astroui.status.init
  init = require "astroui.status.init",
  --- @see astroui.status.provider
  provider = require "astroui.status.provider",
  --- @see astroui.status.utils
  utils = require "astroui.status.utils",
}
