local root = assert(vim.env.ASTROUI_TEST_ROOT, "Missing ASTROUI_TEST_ROOT")
local environment = assert(vim.env.ASTROUI_TEST_ENVIRONMENT, "Missing ASTROUI_TEST_ENVIRONMENT")

vim.env.LAZY_OFFLINE = "1"
vim.opt.rtp:prepend(root)
for _, path in ipairs { "data/nvim/lazy/astrocore", "data/nvim/lazy/heirline.nvim", "data/nvim/lazy/mini.test" } do
  vim.opt.rtp:prepend(environment .. "/" .. path)
  package.path = environment
    .. "/"
    .. path
    .. "/lua/?.lua;"
    .. environment
    .. "/"
    .. path
    .. "/lua/?/init.lua;"
    .. package.path
end
package.path = root
  .. "/lua/?.lua;"
  .. root
  .. "/lua/?/init.lua;"
  .. environment
  .. "/lua/?.lua;"
  .. environment
  .. "/lua/?/init.lua;"
  .. package.path
vim.g.astroui_fixture_loaded = require "astroui" ~= nil
