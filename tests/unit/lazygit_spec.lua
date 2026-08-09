local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_lazygit(lazygit_config, options, callback)
  options = options or {}
  local astroui = options.astroui
    or {
      config = { lazygit = lazygit_config },
      get_hlgroup = options.get_hlgroup or function() return {} end,
    }
  local loaded = vim.tbl_extend("force", { astroui = astroui }, options.loaded or {})
  return helpers.with_module("astroui.lazygit", { loaded = loaded, vim = options.vim }, callback)
end

local function with_temp_path(callback)
  local path = vim.fn.tempname()
  local ok, result = xpcall(function() return callback(path) end, debug.traceback)
  vim.fn.delete(path)
  if not ok then error(result, 0) end
  return result
end

local function with_value(target, name, value, callback)
  local original = target[name]
  target[name] = value
  local ok, result = xpcall(callback, debug.traceback)
  target[name] = original
  if not ok then error(result, 0) end
  return result
end

local function with_environment(name, value, callback) return with_value(vim.env, name, value, callback) end

local function setup_api(overrides)
  return vim.tbl_extend("force", {
    nvim_create_augroup = function() return 1 end,
    nvim_create_autocmd = function() end,
  }, overrides or {})
end

T["AUI-LAZYGIT-HARNESS-01 resolves the LazyGit cluster without external tools"] = function()
  assert.is_table(require "astroui.lazygit")
end

T["AUI-LAZYGIT-CONFIG-01 skips disabled and absent configuration"] = function()
  local function assert_skipped(lazygit_config)
    local writes = 0
    with_lazygit(lazygit_config, {
      vim = {
        fn = { writefile = function() writes = writes + 1 end },
        api = setup_api(),
      },
    }, function(lazygit)
      lazygit.update_config()
      lazygit.setup()
    end)
    assert.equals(0, writes)
  end

  assert_skipped(false)
  assert_skipped(nil)
end

T["AUI-LAZYGIT-YAML-01 serializes nested maps, lists, and empty collections deterministically"] = function()
  with_temp_path(function(path)
    with_lazygit({
      theme_path = path,
      config = {
        empty_dict = vim.empty_dict(),
        empty_list = {},
        enabled = true,
        list = { "text", 12, false },
        map = { beta = "B", alpha = "A" },
        number = 3.5,
        ["unsafe key"] = "value",
      },
    }, nil, function(lazygit) lazygit.update_config() end)

    assert.same({
      "empty_dict: {}",
      "empty_list: []",
      "enabled: true",
      "gui:",
      "  theme: {}",
      "list:",
      '  - "text"',
      "  - 12",
      "  - false",
      "map:",
      '  alpha: "A"',
      '  beta: "B"',
      "number: 3.5",
      '"unsafe key": "value"',
    }, vim.fn.readfile(path))
  end)
end

T["AUI-LAZYGIT-YAML-02 emits safe numeric keys and quotes unsafe string keys"] = function()
  with_temp_path(function(path)
    with_lazygit({
      theme_path = path,
      config = {
        [5] = "number key",
        ["quoted:key"] = "colon",
        ["safe_key-2"] = "safe",
        ["unsafe key"] = "space",
      },
    }, nil, function(lazygit) lazygit.update_config() end)

    assert.same({
      '5: "number key"',
      "gui:",
      "  theme: {}",
      '"quoted:key": "colon"',
      'safe_key-2: "safe"',
      '"unsafe key": "space"',
    }, vim.fn.readfile(path))
  end)
end

T["AUI-LAZYGIT-YAML-03 quotes strings and preserves numeric and boolean scalars"] = function()
  with_temp_path(function(path)
    with_lazygit({
      theme_path = path,
      config = { boolean = false, escaped = 'line\n"quote"', number = 0, omitted = nil },
    }, nil, function(lazygit) lazygit.update_config() end)

    assert.same({
      "boolean: false",
      'escaped: "line\\n\\"quote\\""',
      "gui:",
      "  theme: {}",
      "number: 0",
    }, vim.fn.readfile(path))
  end)
end

T["AUI-LAZYGIT-YAML-04 rejects unsupported scalar values"] = function()
  with_temp_path(function(path)
    with_lazygit({ theme_path = path, config = { unsupported = function() end } }, nil, function(lazygit)
      local ok, error_message = pcall(lazygit.update_config)
      assert.is_false(ok)
      assert.is_true(error_message:find("Cannot serialize function as YAML", 1, true) ~= nil)
      assert.is_nil(vim.uv.fs_stat(path))
    end)
  end)
end

T["AUI-LAZYGIT-THEME-01 converts numeric fg and bg colors before ordered modifiers"] = function()
  with_temp_path(function(path)
    local highlights = {
      Foreground = { fg = 0x010203 },
      Background = { bg = 0x040506 },
    }
    with_lazygit({
      theme_path = path,
      theme = {
        activeBorderColor = {
          fg = "Foreground",
          bg = "Background",
          bold = true,
          reverse = true,
          underline = true,
          strikethrough = true,
        },
      },
    }, { get_hlgroup = function(name) return highlights[name] end }, function(lazygit) lazygit.update_config() end)

    assert.same({
      "gui:",
      "  theme:",
      "    activeBorderColor:",
      '      - "#010203"',
      '      - "#040506"',
      '      - "bold"',
      '      - "reverse"',
      '      - "underline"',
      '      - "strikethrough"',
    }, vim.fn.readfile(path))
  end)
end

T["AUI-LAZYGIT-THEME-02 gives user config.config theme values deep-merge precedence"] = function()
  with_temp_path(function(path)
    with_lazygit({
      theme_path = path,
      theme = { defaultFgColor = { fg = "Default" } },
      config = { gui = { theme = { defaultFgColor = { "user" }, userColor = { "custom" } } } },
    }, { get_hlgroup = function() return { fg = 0x010203 } end }, function(lazygit) lazygit.update_config() end)

    assert.same({
      "gui:",
      "  theme:",
      "    defaultFgColor:",
      '      - "user"',
      "    userColor:",
      '      - "custom"',
    }, vim.fn.readfile(path))
  end)
end

T["AUI-LAZYGIT-TERMINAL-01 dispatches numeric palette entries only to stdout channel one"] = function()
  with_temp_path(function(path)
    local uis = { { chan = 2, stdout_tty = true }, { chan = 1, stdout_tty = false } }
    local sent = {}
    with_lazygit({ theme_path = path, theme = { [13] = { fg = "Palette" } } }, {
      get_hlgroup = function() return { fg = 0x0a0b0c } end,
      vim = {
        api = {
          nvim_list_uis = function() return uis end,
          nvim_ui_send = function(data) table.insert(sent, data) end,
        },
      },
    }, function(lazygit)
      lazygit.update_config()
      assert.same({}, sent)

      uis = { { chan = 1, stdout_tty = true } }
      lazygit.update_config()
      assert.same({ "\27]4;13;#0a0b0c\7" }, sent)
    end)
  end)
end

T["AUI-LAZYGIT-TERMINAL-02 falls back to io.write without nvim_ui_send"] = function()
  with_temp_path(function(path)
    local sent = {}
    with_lazygit({ theme_path = path, theme = { [14] = { fg = "Palette" } } }, {
      get_hlgroup = function() return { fg = 0x0d0e0f } end,
      vim = { api = { nvim_list_uis = function() return { { chan = 1, stdout_tty = true } } end } },
    }, function(lazygit)
      with_value(vim.api, "nvim_ui_send", nil, function()
        with_value(io, "write", function(data) table.insert(sent, data) end, lazygit.update_config)
      end)
    end)
    assert.same({ "\27]4;14;#0d0e0f\7" }, sent)
  end)
end

T["AUI-LAZYGIT-TERMINAL-03 protects palette dispatch failures and writes the theme file"] = function()
  with_temp_path(function(path)
    with_lazygit({ theme_path = path, theme = { [15] = { fg = "Palette" } } }, {
      get_hlgroup = function() return { fg = 0x101112 } end,
      vim = {
        api = {
          nvim_list_uis = function() return { { chan = 1, stdout_tty = true } } end,
          nvim_ui_send = function() error "terminal unavailable" end,
        },
      },
    }, function(lazygit) assert.has_no.errors(lazygit.update_config) end)
    assert.same({ "gui:", "  theme: {}" }, vim.fn.readfile(path))
  end)
end

T["AUI-LAZYGIT-SETUP-01 schedules a write only when the theme file is missing"] = function()
  local writes = 0
  with_environment("LG_CONFIG_FILE", nil, function()
    with_lazygit({ theme_path = "/tmp/astroui-lazygit-missing.yml" }, {
      vim = {
        uv = { fs_stat = function() end },
        fn = {
          executable = function() return 0 end,
          writefile = function()
            writes = writes + 1
            return 0
          end,
        },
        api = setup_api(),
      },
    }, function(lazygit, context)
      lazygit.setup()
      context.drain()
    end)
  end)
  assert.equals(1, writes)
end

T["AUI-LAZYGIT-SETUP-02 does not schedule a write when the theme file exists"] = function()
  local writes = 0
  with_environment("LG_CONFIG_FILE", nil, function()
    with_lazygit({ theme_path = "/tmp/astroui-lazygit-present.yml" }, {
      vim = {
        uv = { fs_stat = function() return { type = "file" } end },
        fn = {
          executable = function() return 0 end,
          writefile = function()
            writes = writes + 1
            return 0
          end,
        },
        api = setup_api(),
      },
    }, function(lazygit, context)
      lazygit.setup()
      context.drain()
    end)
  end)
  assert.equals(0, writes)
end

T["AUI-LAZYGIT-SETUP-03 composes an existing LG_CONFIG_FILE before the normalized theme path"] = function()
  local theme_path = "/tmp/astroui-lazygit/../theme.yml"
  with_environment("LG_CONFIG_FILE", "/tmp/existing.yml", function()
    with_lazygit({ theme_path = theme_path }, {
      vim = {
        uv = { fs_stat = function() return { type = "file" } end },
        api = setup_api(),
      },
    }, function(lazygit)
      lazygit.setup()
      assert.equals(vim.fs.normalize("/tmp/existing.yml," .. theme_path), vim.env.LG_CONFIG_FILE)
    end)
  end)
end

T["AUI-LAZYGIT-SETUP-04 discovers lazygit config through the AstroCore command boundary"] = function()
  local commands = {}
  with_environment("LG_CONFIG_FILE", nil, function()
    with_lazygit({ theme_path = "/tmp/astroui-lazygit-theme.yml" }, {
      loaded = {
        astrocore = {
          cmd = function(arguments, suppress_errors)
            table.insert(commands, { arguments = arguments, suppress_errors = suppress_errors })
            return "/tmp/lazygit-config\nignored"
          end,
        },
      },
      vim = {
        uv = { fs_stat = function() return { type = "file" } end },
        fn = { executable = function() return 1 end },
        api = setup_api(),
      },
    }, function(lazygit)
      lazygit.setup()
      assert.same({ { arguments = { "lazygit", "-cd" }, suppress_errors = false } }, commands)
      assert.equals("/tmp/lazygit-config/config.yml,/tmp/astroui-lazygit-theme.yml", vim.env.LG_CONFIG_FILE)
    end)
  end)
end

T["AUI-LAZYGIT-SETUP-05 leaves only the normalized theme path when lazygit is unavailable"] = function()
  local theme_path = "/tmp/astroui-lazygit/../theme.yml"
  with_environment("LG_CONFIG_FILE", nil, function()
    with_lazygit({ theme_path = theme_path }, {
      vim = {
        uv = { fs_stat = function() return { type = "file" } end },
        fn = { executable = function() return 0 end },
        api = setup_api(),
      },
    }, function(lazygit)
      lazygit.setup()
      assert.equals(vim.fs.normalize(theme_path), vim.env.LG_CONFIG_FILE)
    end)
  end)
end

T["AUI-LAZYGIT-SETUP-06 refreshes the theme once after repeated setup"] = function()
  with_temp_path(function(path)
    local group_ids = {}
    local next_group = 0
    local grouped_callbacks = {}
    local ungrouped_callbacks = {}
    local writes = 0
    local writefile = vim.fn.writefile
    with_environment("LG_CONFIG_FILE", nil, function()
      with_lazygit({ theme_path = path }, {
        vim = {
          uv = { fs_stat = function() return { type = "file" } end },
          fn = {
            executable = function() return 0 end,
            writefile = function(lines, target)
              writes = writes + 1
              return writefile(lines, target)
            end,
          },
          api = setup_api {
            nvim_create_augroup = function(name, options)
              if not group_ids[name] then
                next_group = next_group + 1
                group_ids[name] = next_group
              end
              local group = group_ids[name]
              if options.clear then grouped_callbacks[group] = {} end
              return group
            end,
            nvim_create_autocmd = function(event, options)
              if event == "User" and options.pattern == "AstroColorScheme" then
                if options.group then
                  grouped_callbacks[options.group] = grouped_callbacks[options.group] or {}
                  table.insert(grouped_callbacks[options.group], options.callback)
                else
                  table.insert(ungrouped_callbacks, options.callback)
                end
              end
            end,
          },
        },
      }, function(lazygit, context)
        lazygit.setup()
        lazygit.setup()
        for _, callbacks in pairs(grouped_callbacks) do
          for _, callback in ipairs(callbacks) do
            callback()
          end
        end
        for _, callback in ipairs(ungrouped_callbacks) do
          callback()
        end
        context.drain()
      end)
    end)
    assert.equals(1, writes)
    assert.same({ "gui:", "  theme: {}" }, vim.fn.readfile(path))
  end)
end

return T
