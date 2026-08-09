local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_global(name, value, callback)
  local original = vim.g[name]
  vim.g[name] = value
  local ok, result = xpcall(callback, debug.traceback)
  vim.g[name] = original
  if not ok then error(result, 0) end
  return result
end

local function with_astroui(config, options, callback)
  options = options or {}
  local lazygit = options.lazygit or { setup = function() end }
  local loaded = vim.tbl_extend("force", {
    ["astroui.config"] = config,
    ["astroui.lazygit"] = lazygit,
  }, options.loaded or {})
  return helpers.with_module("astroui", {
    loaded = loaded,
    vim = options.vim,
  }, function(astroui) return callback(astroui, lazygit) end)
end

T["AUI-CONFIG-01 exposes selected defaults from fresh module state"] = function()
  local status_config = { marker = "status-defaults" }
  helpers.with_module("astroui.config", {
    loaded = { ["astroui.status.config"] = status_config },
  }, function(config)
    assert.is_nil(config.colorscheme)
    assert.same({}, config.folding)
    assert.same({}, config.highlights)
    assert.same({}, config.icons)
    assert.same({}, config.text_icons)
    assert.equals(status_config, config.status)
    assert.is_false(config.lazygit)
  end)
end

T["AUI-LAZY-SPEC-01 declares the AstroUI plugin identity"] = function()
  local spec = dofile(require("config").root .. "/lazy.lua")

  assert.equals("AstroNvim/astroui", spec[1])
end

T["AUI-LAZY-SPEC-02 preserves every documented opts_extend path"] = function()
  local spec = dofile(require("config").root .. "/lazy.lua")
  local expected = {
    "status.winbar.enabled.filetype",
    "status.winbar.enabled.buftype",
    "status.winbar.enabled.bufname",
    "status.winbar.disabled.filetype",
    "status.winbar.disabled.buftype",
    "status.winbar.disabled.bufname",
  }

  assert.same(expected, spec.opts_extend)
end

T["AUI-STATUS-API-01 aggregates the documented status modules"] = function()
  local modules = {
    component = { name = "component" },
    condition = { name = "condition" },
    heirline = { name = "heirline" },
    hl = { name = "hl" },
    init = { name = "init" },
    provider = { name = "provider" },
    utils = { name = "utils" },
  }
  local loaded = {}
  for name, module in pairs(modules) do
    loaded["astroui.status." .. name] = module
  end

  helpers.with_module("astroui.status", { loaded = loaded }, function(status)
    for name, module in pairs(modules) do
      assert.equals(module, status[name])
    end
  end)
end

T["AUI-INIT-SETUP-01 force-merges nested configuration without altering user input"] = function()
  local defaults = {
    folding = { enabled = true, methods = { primary = "lsp", fallback = "indent" } },
    highlights = { init = { Normal = { fg = "default", bold = true } } },
    icons = { Existing = "E" },
    text_icons = {},
    status = {},
    lazygit = false,
  }
  local user = {
    folding = { methods = { primary = "treesitter" } },
    highlights = { init = { Normal = { bg = "override" } } },
    icons = { User = "U" },
  }
  local user_snapshot = vim.deepcopy(user)
  local setup_calls = 0

  with_astroui(defaults, { lazygit = { setup = function() setup_calls = setup_calls + 1 end } }, function(astroui)
    astroui.setup(user)

    assert.equals("treesitter", astroui.config.folding.methods.primary)
    assert.equals("indent", astroui.config.folding.methods.fallback)
    assert.equals("default", astroui.config.highlights.init.Normal.fg)
    assert.equals("override", astroui.config.highlights.init.Normal.bg)
    assert.is_true(astroui.config.highlights.init.Normal.bold)
    assert.equals("E", astroui.config.icons.Existing)
    assert.equals("U", astroui.config.icons.User)
    assert.same(user_snapshot, user)
    assert.equals(1, setup_calls)
  end)
end

T["AUI-INIT-SETUP-02 delegates every setup call to LazyGit"] = function()
  local setup_calls = 0
  with_astroui({ highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
    lazygit = { setup = function() setup_calls = setup_calls + 1 end },
  }, function(astroui)
    astroui.setup {}
    astroui.setup {}
  end)

  assert.equals(2, setup_calls)
end

T["AUI-INIT-COLORSCHEME-01 skips highlight dispatch without a colorscheme and emits the user event"] = function()
  local autocmd
  local highlights = {}
  local events = {}
  local api = {
    nvim_create_augroup = function() return 7 end,
    nvim_create_autocmd = function(event, options)
      assert.equals("ColorScheme", event)
      autocmd = options
      return 8
    end,
    nvim_exec_autocmds = function(event, options) table.insert(events, { event = event, options = options }) end,
    nvim_set_hl = function(_, group, specification)
      table.insert(highlights, { group = group, specification = specification })
    end,
  }

  with_global("colors_name", nil, function()
    with_astroui(
      { highlights = {}, icons = {}, text_icons = {}, lazygit = false },
      { vim = { api = api } },
      function(astroui)
        astroui.setup {}
        autocmd.callback()

        assert.equals(0, #highlights)
        assert.equals(1, #events)
        assert.equals("User", events[1].event)
        assert.equals("AstroColorScheme", events[1].options.pattern)
        assert.is_false(events[1].options.modeline)
      end
    )
  end)
end

T["AUI-INIT-COLORSCHEME-02 applies init then scheme function highlights before the user event"] = function()
  local autocmd
  local highlights = {}
  local events = {}
  local api = {
    nvim_create_augroup = function() return 7 end,
    nvim_create_autocmd = function(_, options) autocmd = options end,
    nvim_exec_autocmds = function(event, options) table.insert(events, { event = event, options = options }) end,
    nvim_set_hl = function(_, group, specification)
      table.insert(highlights, { group = group, specification = specification })
    end,
  }

  with_global("colors_name", "moon", function()
    with_astroui({
      highlights = {
        init = { AUIInit = { fg = "#111111" } },
        moon = function(name)
          assert.equals("moon", name)
          return { AUIScheme = { bg = "#222222" } }
        end,
      },
      icons = {},
      text_icons = {},
      lazygit = false,
    }, { vim = { api = api } }, function(astroui)
      astroui.setup {}
      autocmd.callback()

      assert.equals("AUIInit", highlights[1].group)
      assert.equals("AUIScheme", highlights[2].group)
      assert.equals("User", events[1].event)
      assert.equals("AstroColorScheme", events[1].options.pattern)
    end)
  end)
end

T["AUI-INIT-COLORSCHEME-03 applies init then scheme table highlights"] = function()
  local autocmd
  local highlights = {}
  local api = {
    nvim_create_augroup = function() return 7 end,
    nvim_create_autocmd = function(_, options) autocmd = options end,
    nvim_exec_autocmds = function() end,
    nvim_set_hl = function(_, group) table.insert(highlights, group) end,
  }

  with_global("colors_name", "dawn", function()
    with_astroui({
      highlights = { init = { AUIInit = {} }, dawn = { AUIScheme = {} } },
      icons = {},
      text_icons = {},
      lazygit = false,
    }, { vim = { api = api } }, function(astroui)
      astroui.setup {}
      autocmd.callback()
      assert.same({ "AUIInit", "AUIScheme" }, highlights)
    end)
  end)
end

T["AUI-INIT-SET-COLORSCHEME-01 skips colorscheme changes in VS Code"] = function()
  local calls = 0
  with_global("vscode", true, function()
    with_astroui({ colorscheme = "moon", highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
      vim = { cmd = { colorscheme = function() calls = calls + 1 end } },
    }, function(astroui) astroui.set_colorscheme() end)
  end)

  assert.equals(0, calls)
end

T["AUI-INIT-SET-COLORSCHEME-02 ignores an absent colorscheme"] = function()
  local calls = 0
  with_global("vscode", nil, function()
    with_astroui({ colorscheme = nil, highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
      vim = { cmd = { colorscheme = function() calls = calls + 1 end } },
    }, function(astroui) astroui.set_colorscheme() end)
  end)

  assert.equals(0, calls)
end

T["AUI-INIT-SET-COLORSCHEME-03 applies the configured colorscheme"] = function()
  local selected
  with_global("vscode", nil, function()
    with_astroui({ colorscheme = "moon", highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
      vim = { cmd = { colorscheme = function(name) selected = name end } },
    }, function(astroui) astroui.set_colorscheme() end)
  end)

  assert.equals("moon", selected)
end

T["AUI-INIT-SET-COLORSCHEME-04 notifies when the configured colorscheme fails"] = function()
  local notification
  with_global("vscode", nil, function()
    with_astroui({ colorscheme = "missing", highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
      loaded = {
        astrocore = {
          notify = function(message, level) notification = { message = message, level = level } end,
        },
      },
      vim = {
        cmd = {
          colorscheme = function() error "missing colorscheme" end,
        },
      },
    }, function(astroui) astroui.set_colorscheme() end)
  end)

  assert.equals("Error setting up colorscheme: `missing`", notification.message)
  assert.equals(vim.log.levels.ERROR, notification.level)
end

T["AUI-INIT-HLGROUP-01 returns the fallback for a missing highlight group"] = function()
  local fallback = { fg = "fallback" }
  with_astroui({ highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
    vim = { fn = { hlexists = function() return 0 end } },
  }, function(astroui)
    assert.equals(fallback, astroui.get_hlgroup("Missing", fallback))
    assert.same({}, astroui.get_hlgroup "Missing")
  end)
end

T["AUI-INIT-HLGROUP-02 normalizes missing foreground and background values"] = function()
  with_astroui({ highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
    vim = {
      fn = { hlexists = function() return 1 end },
      api = { nvim_get_hl = function() return { bold = true } end },
    },
  }, function(astroui) assert.same({ fg = "NONE", bg = "NONE", bold = true }, astroui.get_hlgroup "Partial") end)
end

T["AUI-INIT-HLGROUP-03 normalizes reverse highlights by swapping colors"] = function()
  with_astroui({ highlights = {}, icons = {}, text_icons = {}, lazygit = false }, {
    vim = {
      fn = { hlexists = function() return 1 end },
      api = { nvim_get_hl = function() return { fg = 1, bg = 2, reverse = true } end },
    },
  }, function(astroui) assert.same({ fg = 2, bg = 1 }, astroui.get_hlgroup "Reverse") end)
end

T["AUI-INIT-ICON-01 selects icon or text icon and respects fallback and padding"] = function()
  with_astroui(
    {
      highlights = {},
      icons = { GitAdd = "N", Spinner1 = "1", Spinner2 = "2" },
      text_icons = { GitAdd = "T" },
      lazygit = false,
    },
    nil,
    function(astroui)
      with_global("icons_enabled", true, function() assert.equals("N  ", astroui.get_icon("GitAdd", 2)) end)
      with_global("icons_enabled", false, function()
        assert.equals("T ", astroui.get_icon("GitAdd", 1))
        assert.equals("", astroui.get_icon("GitAdd", 1, true))
      end)
    end
  )
end

T["AUI-INIT-SPINNER-01 collects sequential spinner icons and returns nil when absent"] = function()
  with_astroui(
    {
      highlights = {},
      icons = { Spinner1 = "1", Spinner2 = "2" },
      text_icons = {},
      lazygit = false,
    },
    nil,
    function(astroui)
      with_global("icons_enabled", true, function()
        assert.same({ "1", "2" }, astroui.get_spinner "Spinner")
        assert.is_nil(astroui.get_spinner "Missing")
      end)
    end
  )
end

return T
