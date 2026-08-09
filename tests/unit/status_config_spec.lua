local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_config(options, callback)
  options = options or {}
  local astroui = { config = {}, get_icon = function(kind) return kind end }
  local loaded = vim.tbl_extend("force", { astroui = astroui }, options.loaded or {})
  return helpers.with_module("astroui.status.config", { loaded = loaded, vim = options.vim }, function(config, context)
    astroui.config.status = config
    return callback(config, context)
  end)
end

T["AUI-STATUS-CONFIG-01 preserves selected default contracts"] = function()
  with_config(nil, function(config)
    assert.same({}, config.attributes)
    assert.same({}, config.fallback_colors)
    assert.same({}, config.sign_handlers)
    assert.equals(false, config.components.mode.mode_text)
    assert.equals("Untitled", config.providers.filename.fallback)
    assert.equals(".", config.providers.bufnr.suffix)
    assert.is_true(config.providers.virtual_env.conda.ignore_base)
    assert.is_true(config.providers.lsp_client_names.integrations.conform)
  end)
end

T["AUI-STATUS-CONFIG-02 dispatches branch, diff, and diagnostics fallbacks in order"] = function()
  local calls = {}
  with_config({
    loaded = {
      ["fzf-lua"] = { git_branches = function() table.insert(calls, "fzf-branch") end },
      ["telescope.builtin"] = { git_branches = function() table.insert(calls, "telescope-branch") end },
      snacks = { picker = { git_branches = function() table.insert(calls, "snacks-branch") end } },
    },
  }, function(config) config.components.git_branch.on_click.callback() end)
  with_config({
    loaded = {
      ["telescope.builtin"] = {
        git_status = function(options) table.insert(calls, options.use_file_path and "telescope-diff" or "bad") end,
      },
    },
  }, function(config) config.components.git_diff.on_click.callback() end)
  with_config({
    loaded = { snacks = { picker = { diagnostics_buffer = function() table.insert(calls, "snacks-diagnostics") end } } },
  }, function(config) config.components.diagnostics.on_click.callback() end)

  assert.same({ "fzf-branch", "telescope-diff", "snacks-diagnostics" }, calls)
end

T["AUI-STATUS-CONFIG-03 dispatches sign handlers by name then namespace then text highlight"] = function()
  local calls = {}
  local args = { mods = "", sign = { name = "Name", namespace = "Namespace", texthl = "TextHighlight" } }
  with_config({
    loaded = {
      ["astroui.status.utils"] = { statuscolumn_clickargs = function() return args end },
    },
  }, function(config)
    config.sign_handlers = {
      Name = function() table.insert(calls, "name") end,
      Namespace = function() table.insert(calls, "namespace") end,
      TextHighlight = function() table.insert(calls, "texthl") end,
    }
    config.components.signcolumn.on_click.callback()
    config.sign_handlers.Name = nil
    config.components.signcolumn.on_click.callback()
    config.sign_handlers.Namespace = nil
    config.components.signcolumn.on_click.callback()
    args.sign = nil
    config.components.signcolumn.on_click.callback()
  end)

  assert.same({ "name", "namespace", "texthl" }, calls)
end

T["AUI-STATUS-CONFIG-04 gives control line clicks to DAP before sign dispatch"] = function()
  local calls = {}
  local args = { mods = "c", sign = { name = "Breakpoint", namespace = "", texthl = "" } }
  with_config({
    loaded = {
      dap = { toggle_breakpoint = function() table.insert(calls, "dap") end },
      ["astroui.status.utils"] = { statuscolumn_clickargs = function() return args end },
    },
  }, function(config)
    config.sign_handlers.Breakpoint = function() table.insert(calls, "sign") end
    config.components.numbercolumn.on_click.callback()
    args.mods = ""
    config.components.numbercolumn.on_click.callback()
  end)

  assert.same({ "dap", "sign" }, calls)
end

T["AUI-STATUS-CONFIG-05 schedules configured redraw callbacks"] = function()
  local redraws = 0
  with_config({ vim = { cmd = { redrawstatus = function() redraws = redraws + 1 end } } }, function(config, context)
    config.components.mode.update.callback()
    config.components.git_branch.update.callback()
    config.components.git_diff.update.callback()
    config.components.lsp.lsp_progress.update.callback()
    config.components.lsp.lsp_client_names.update.callback()
    context.drain()
  end)

  assert.equals(5, redraws)
end

T["AUI-STATUS-CONFIG-06 maps fold glyph clicks to close and open commands"] = function()
  local commands = {}
  local fillchars = vim.opt_local.fillchars:get()
  local args = { char = fillchars.foldopen or "FoldOpened" }
  with_config({
    loaded = {
      ["astroui.status.utils"] = { statuscolumn_clickargs = function() return args end },
    },
    vim = { cmd = function(command) table.insert(commands, command) end },
  }, function(config)
    config.components.foldcolumn.on_click.callback()
    args.char = fillchars.foldclose or "FoldClosed"
    config.components.foldcolumn.on_click.callback()
  end)

  assert.same({ "norm! zc", "norm! zo" }, commands)
end

return T
