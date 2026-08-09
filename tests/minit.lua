local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"
config.assert_ready_environment()

vim.env.LAZY_OFFLINE = "1"
package.path = config.test_lua_dir
  .. "/?.lua;"
  .. config.test_lua_dir
  .. "/?/init.lua;"
  .. config.root
  .. "/lua/?.lua;"
  .. config.root
  .. "/lua/?/init.lua;"
  .. package.path
vim.opt.rtp:prepend(config.root)
for index = #config.dependencies, 1, -1 do
  local dependency_path = config.test_root .. "/" .. config.dependencies[index].path
  vim.opt.rtp:prepend(dependency_path)
  package.path = dependency_path .. "/lua/?.lua;" .. dependency_path .. "/lua/?/init.lua;" .. package.path
end

require("lazy.minit").setup {
  root = config.plugin_root,
  lockfile = config.lockfile,
  local_spec = false,
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  rocks = { enabled = false },
  pkg = { cache = config.state_dir .. "/lazy/pkg-cache.lua" },
  readme = { root = config.state_dir .. "/lazy/readme" },
  state = config.state_dir .. "/lazy/state.json",
  performance = { cache = { enabled = false } },
}

require("mini.test").setup()
