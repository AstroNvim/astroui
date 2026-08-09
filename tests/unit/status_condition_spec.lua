local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_condition(options, callback)
  options = options or {}
  return helpers.with_module("astroui.status.condition", {
    loaded = options.loaded,
    vim = options.vim,
  }, callback)
end

local function with_buffer_options(callback)
  local current = vim.api.nvim_get_current_buf()
  local alternate = vim.api.nvim_create_buf(false, true)
  local original = {
    current = {
      name = vim.api.nvim_buf_get_name(current),
      filetype = vim.bo[current].filetype,
      buftype = vim.bo[current].buftype,
      modified = vim.bo[current].modified,
      modifiable = vim.bo[current].modifiable,
      readonly = vim.bo[current].readonly,
    },
    alternate = { filetype = vim.bo[alternate].filetype, buftype = vim.bo[alternate].buftype },
  }
  local ok, result = xpcall(function() return callback(current, alternate) end, debug.traceback)
  vim.bo[current].modifiable = true
  vim.api.nvim_buf_set_name(current, original.current.name)
  vim.bo[current].filetype = original.current.filetype
  vim.bo[current].buftype = original.current.buftype
  vim.bo[current].modified = original.current.modified
  vim.bo[current].modifiable = original.current.modifiable
  vim.bo[current].readonly = original.current.readonly
  vim.api.nvim_buf_delete(alternate, { force = true })
  if not ok then error(result, 0) end
  return result
end

T["AUI-STATUS-CONDITION-01 matches current, explicit, and invalid buffers"] = function()
  with_buffer_options(function(current, alternate)
    vim.bo[current].filetype = "lua"
    vim.bo[current].buftype = ""
    vim.api.nvim_buf_set_name(current, "/tmp/status_condition.lua")
    vim.bo[alternate].filetype = "help"
    vim.bo[alternate].buftype = "nofile"
    vim.api.nvim_buf_set_name(alternate, "/tmp/status_condition.txt")

    with_condition(nil, function(condition)
      assert.is_true(condition.buffer_matches { filetype = "lua" })
      assert.is_true(condition.buffer_matches({ filetype = "help", buftype = "nofile" }, alternate, "and"))
      assert.is_true(condition.buffer_matches({ filetype = "lua", bufname = "%.txt$" }, alternate, "or"))
      assert.is_false(condition.buffer_matches({ filetype = "lua", buftype = "" }, alternate, "and"))
      assert.is_false(condition.buffer_matches({ filetype = "lua" }, -1))
      assert.is_true(condition.buffer_matches({}, -1, "and"))
    end)
  end)
end

T["AUI-STATUS-CONDITION-02 evaluates window, recording, search, and showcmd state"] = function()
  local original_window = vim.g.actual_curwin
  local original_hlsearch = vim.v.hlsearch
  local original_showcmdloc = vim.opt.showcmdloc:get()
  vim.g.actual_curwin = tostring(vim.api.nvim_get_current_win())
  vim.v.hlsearch = 1
  vim.opt.showcmdloc = "statusline"
  with_condition({ vim = { fn = { reg_recording = function() return "q" end } } }, function(condition)
    assert.is_true(condition.is_active())
    assert.is_true(condition.is_macro_recording())
    assert.is_true(condition.is_hlsearch())
    assert.is_true(condition.is_statusline_showcmd())
  end)
  vim.g.actual_curwin = original_window
  vim.v.hlsearch = original_hlsearch
  vim.opt.showcmdloc = original_showcmdloc
end

T["AUI-STATUS-CONDITION-03 recognizes git changes and buffer states for direct and table buffers"] = function()
  with_buffer_options(function(current, alternate)
    vim.b[current].gitsigns_head = "main"
    vim.b[alternate].gitsigns_status_dict = { added = 1, removed = 0, changed = 0 }
    vim.bo[current].modified = true
    vim.bo[current].modifiable = false
    vim.bo[alternate].filetype = "lua"
    vim.bo[alternate].buftype = ""
    with_condition(nil, function(condition)
      assert.is_truthy(condition.is_git_repo())
      assert.is_truthy(condition.is_git_repo { bufnr = alternate })
      assert.is_true(condition.git_changed(alternate))
      assert.is_true(condition.file_modified { bufnr = current })
      assert.is_true(condition.file_read_only(current))
      assert.is_true(condition.has_filetype { bufnr = alternate })
      assert.is_true(condition.is_file(alternate))
    end)
    vim.b[current].gitsigns_head = nil
    vim.b[alternate].gitsigns_status_dict = nil
    vim.b[alternate].minidiff_summary = { add = 0, delete = 1, change = 0 }
    with_condition(nil, function(condition)
      assert.is_true(condition.git_changed { bufnr = alternate })
      assert.is_nil(condition.is_git_repo(alternate))
    end)
    vim.b[alternate].minidiff_summary = nil
  end)
end

T["AUI-STATUS-CONDITION-04 checks diagnostics and virtual environments"] = function()
  local original_virtual_env = vim.env.VIRTUAL_ENV
  local original_conda_env = vim.env.CONDA_DEFAULT_ENV
  with_condition(
    { vim = { diagnostic = { count = function(bufnr) return bufnr == 9 and { [1] = 1 } or {} end } } },
    function(condition)
      assert.is_true(condition.has_diagnostics { bufnr = 9 })
      assert.is_false(condition.has_diagnostics(8))
    end
  )
  vim.env.VIRTUAL_ENV = "/tmp/venv"
  vim.env.CONDA_DEFAULT_ENV = ""
  with_condition(nil, function(condition) assert.is_true(condition.has_virtual_env()) end)
  vim.env.VIRTUAL_ENV = ""
  vim.env.CONDA_DEFAULT_ENV = "base"
  with_condition(nil, function(condition)
    assert.is_false(condition.has_virtual_env { enabled = true, ignore_base = true })
    assert.is_true(condition.has_virtual_env { enabled = true, ignore_base = false })
    assert.is_false(condition.has_virtual_env { enabled = false })
  end)
  vim.env.VIRTUAL_ENV = original_virtual_env
  vim.env.CONDA_DEFAULT_ENV = original_conda_env
end

T["AUI-STATUS-CONDITION-05 gates Aerial, conform, lint, Treesitter, and early LSP lookup"] = function()
  with_condition({
    loaded = {
      aerial = { get_location = function() end },
      ["astrocore.treesitter"] = { is_enabled = function(bufnr) return bufnr == 12 end },
    },
  }, function(condition)
    assert.equals(package.loaded.aerial, condition.aerial_available())
    assert.is_true(condition.treesitter_available { bufnr = 12 })
    assert.is_false(condition.treesitter_available(11))
  end)
  with_condition({
    loaded = {
      conform = { list_formatters = function(bufnr) return bufnr == 13 and { "stylua" } or {} end },
      ["astrocore.treesitter"] = { is_enabled = function() return false end },
    },
  }, function(condition) assert.is_true(condition.lsp_attached(13)) end)
  with_buffer_options(function(_, alternate)
    vim.bo[alternate].filetype = "lua"
    with_condition({
      loaded = {
        lint = { _resolve_linter_by_ft = function(filetype) return filetype == "lua" and { "luacheck" } or {} end },
      },
    }, function(condition) assert.is_true(condition.lsp_attached { bufnr = alternate }) end)
  end)
  with_condition({
    loaded = {
      ["vim.lsp"] = {},
      astrolsp = helpers.remove,
      conform = helpers.remove,
      lint = helpers.remove,
    },
    vim = { lsp = { get_clients = function() error("vim.lsp.get_clients called before AstroLSP loaded", 0) end } },
  }, function(condition) assert.is_nil(condition.lsp_attached()) end)
end

T["AUI-STATUS-CONDITION-05A recognizes native vim.lsp clients after AstroLSP loads"] = function()
  local query
  with_condition({
    loaded = { ["vim.lsp"] = helpers.remove, astrolsp = {} },
    vim = {
      lsp = {
        get_clients = function(opts)
          query = opts
          return { { id = 1 } }
        end,
      },
    },
  }, function(condition)
    assert.is_true(condition.lsp_attached { bufnr = 14 })
    assert.same({ bufnr = 14 }, query)
  end)
end

T["AUI-STATUS-CONDITION-06 reflects fold, number, and sign options"] = function()
  local original = {
    foldcolumn = vim.opt.foldcolumn:get(),
    number = vim.opt.number:get(),
    relativenumber = vim.opt.relativenumber:get(),
    signcolumn = vim.opt.signcolumn:get(),
  }
  vim.opt.foldcolumn = "1"
  vim.opt.number = false
  vim.opt.relativenumber = true
  vim.opt.signcolumn = "yes"
  with_condition(nil, function(condition)
    assert.is_true(condition.foldcolumn_enabled())
    assert.is_true(condition.numbercolumn_enabled())
    assert.is_true(condition.signcolumn_enabled())
  end)
  vim.opt.foldcolumn = "0"
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "no"
  with_condition(nil, function(condition)
    assert.is_false(condition.foldcolumn_enabled())
    assert.is_false(condition.numbercolumn_enabled())
    assert.is_false(condition.signcolumn_enabled())
  end)
  vim.opt.foldcolumn = original.foldcolumn
  vim.opt.number = original.number
  vim.opt.relativenumber = original.relativenumber
  vim.opt.signcolumn = original.signcolumn
end

return T
