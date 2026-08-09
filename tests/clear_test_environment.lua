local tests_dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
package.path = tests_dir .. "/?.lua;" .. package.path

local config = require "config"
local environment = require "test_environment"

local function filesystem()
  return {
    lstat = vim.uv.fs_lstat,
    mkdir = function(path) return vim.uv.fs_mkdir(path, 448) end,
    rmdir = vim.uv.fs_rmdir,
    unlink = vim.uv.fs_unlink,
    scandir = function(path)
      local scanner, error_message = vim.uv.fs_scandir(path)
      if not scanner then return nil, error_message end
      local entries = {}
      while true do
        local name = vim.uv.fs_scandir_next(scanner)
        if not name then break end
        table.insert(entries, name)
      end
      return entries
    end,
    now = vim.uv.hrtime,
    wait = vim.wait,
  }
end

environment.clear_test_environment(filesystem(), config.root, config.test_root)
