local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function extend_tbl(...)
  local tables = {}
  for index = 1, select("#", ...) do
    local value = select(index, ...)
    if type(value) == "table" then table.insert(tables, value) end
  end
  if #tables < 2 then return vim.deepcopy(tables[1] or {}) end
  return vim.tbl_deep_extend("force", unpack(tables))
end

local function with_component(status_config, options, callback)
  options = options or {}
  local providers = options.providers
    or setmetatable({}, {
      __index = function(_, name)
        return function(opts) return name .. ":" .. (opts and opts.marker or "default") end
      end,
    })
  if rawget(providers, "fill") == nil then providers.fill = function() return "fill" end end
  local utils = options.utils
  if not utils then
    utils = {}
    utils.build_provider = function(opts, provider)
      return opts and { provider = provider, opts = opts, condition = opts.condition, hl = opts.hl } or false
    end
    utils.pad_string = function(_, padding) return "pad:" .. (padding.left or 0) .. ":" .. (padding.right or 0) end
    utils.setup_providers = function(opts, provider_names, setup)
      setup = setup or utils.build_provider
      for index, provider_name in ipairs(provider_names) do
        opts[index] = setup(opts[provider_name], provider_name, index)
      end
      return opts
    end
    utils.surround = function(separator, color, children, condition, update)
      return { separator = separator, color = color, children = children, condition = condition, update = update }
    end
  end
  local loaded = vim.tbl_extend("force", {
    astrocore = { extend_tbl = extend_tbl },
    astroui = { config = { status = status_config } },
    ["astroui.status.condition"] = options.condition or { has_virtual_env = function() return true end },
    ["astroui.status.init"] = options.init or {},
    ["astroui.status.provider"] = providers,
    ["astroui.status.utils"] = utils,
  }, options.loaded or {})

  return helpers.with_module(
    "astroui.status.component",
    { loaded = loaded },
    function(component) return callback(component, providers, utils) end
  )
end

T["AUI-STATUS-COMPONENT-01 fills with defaults and call options"] = function()
  with_component({ components = {}, providers = {} }, nil, function(component)
    local filled = component.fill { priority = 7 }

    assert.equals("fill", filled.provider)
    assert.equals(7, filled.priority)
    assert.is_false(filled.update())
  end)
end

T["AUI-STATUS-COMPONENT-02 merges factory options and keeps provider ordering"] = function()
  local file_info = {
    file_icon = { marker = "default-icon" },
    bufnr = false,
    unique_path = false,
    filename = { marker = "default-name", nested = { defaulted = true } },
    filetype = false,
    file_modified = false,
    file_read_only = false,
    close_button = false,
  }
  local caller = {
    file_icon = { marker = "call-icon" },
    filename = { marker = "call-name", nested = { called = true } },
  }
  local default_snapshot = vim.deepcopy(file_info)
  local caller_snapshot = vim.deepcopy(caller)
  with_component({ components = { file_info = file_info }, providers = {} }, nil, function(component)
    local children = component.file_info(caller)

    assert.equals("file_icon:call-icon", children[1].provider)
    assert.is_false(children[2])
    assert.is_false(children[3])
    assert.equals("filename:call-name", children[4].provider)
    assert.is_true(children[4].opts.nested.defaulted)
    assert.is_true(children[4].opts.nested.called)
  end)
  assert.same(default_snapshot, file_info)
  assert.same(caller_snapshot, caller)
end

T["AUI-STATUS-COMPONENT-03 assigns git and diagnostic provider discriminators"] = function()
  local status_config = {
    components = {
      git_diff = { added = { marker = "add" }, changed = false, removed = { marker = "remove" } },
      diagnostics = { ERROR = { marker = "error" }, WARN = false, INFO = false, HINT = { marker = "hint" } },
    },
    providers = {},
  }
  with_component(status_config, nil, function(component)
    local git = component.git_diff()
    local diagnostics = component.diagnostics()

    assert.equals("git_diff:add", git[1].provider)
    assert.equals("added", git[1].opts.type)
    assert.equals("git_added", git[1].hl.fg)
    assert.is_false(git[2])
    assert.equals("git_diff:remove", git[3].provider)
    assert.equals("removed", git[3].opts.type)
    assert.equals("git_removed", git[3].hl.fg)
    assert.equals("diagnostics:error", diagnostics[1].provider)
    assert.equals("ERROR", diagnostics[1].opts.severity)
    assert.equals("diag_ERROR", diagnostics[1].hl.fg)
    assert.is_false(diagnostics[2])
    assert.equals("diagnostics:hint", diagnostics[4].provider)
    assert.equals("HINT", diagnostics[4].opts.severity)
    assert.equals("diag_HINT", diagnostics[4].hl.fg)
  end)
end

T["AUI-STATUS-COMPONENT-04 resolves named builder providers with padding and surround handoff"] = function()
  local calls = {}
  local utils = {
    pad_string = function(_, padding) return "pad:" .. (padding.left or 0) .. ":" .. (padding.right or 0) end,
    surround = function(separator, color, children, condition, update)
      calls.surround = { separator, color, children, condition, update }
      return { wrapped = children }
    end,
  }
  with_component({ components = {}, providers = {} }, {
    providers = { named = function(opts) return "named:" .. opts.marker end },
    utils = utils,
  }, function(component)
    local condition = function() return true end
    local result = component.builder {
      { provider = "named", opts = { marker = "value" } },
      padding = { left = 2, right = 2 },
      surround = { separator = "left", color = "group", condition = condition, update = "CursorMoved" },
    }

    assert.equals("pad:1:0", result.wrapped[1].provider)
    assert.equals("named:value", result.wrapped[2].provider)
    assert.equals("pad:0:1", result.wrapped[3].provider)
    assert.equals("left", calls.surround[1])
    assert.equals("group", calls.surround[2])
    assert.equals(condition, calls.surround[4])
    assert.equals("CursorMoved", calls.surround[5])
  end)
end

T["AUI-STATUS-COMPONENT-05 uses a blank mode provider and flexible LSP groups"] = function()
  local status_config = {
    components = {
      mode = { mode_text = false, paste = false, spell = false },
      lsp = { lsp_progress = { marker = "progress" }, lsp_client_names = false },
    },
    providers = {},
  }
  local function factory(name)
    return function(opts) return name .. ":" .. (opts and opts.marker or "default") end
  end
  with_component(status_config, {
    providers = {
      mode_text = factory "mode_text",
      str = factory "str",
      paste = factory "paste",
      spell = factory "spell",
      lsp_progress = factory "lsp_progress",
    },
  }, function(component)
    local mode = component.mode()
    local lsp = component.lsp()

    assert.is_false(mode[1])
    assert.equals("str:default", mode[2].provider)
    assert.is_false(mode[3])
    assert.equals(1, lsp[1].flexible)
    assert.equals("lsp_progress:progress", lsp[1][1].provider)
    assert.equals("str:progress", lsp[1][2].provider)
    assert.is_false(lsp[2])
  end)
end

T["AUI-STATUS-COMPONENT-06 initializes breadcrumb and path callbacks and virtual environment surround"] = function()
  local calls = {}
  local init = {
    breadcrumbs = function(opts)
      calls.breadcrumbs = opts
      return function() calls.breadcrumbs_called = true end
    end,
    separated_path = function(opts)
      calls.path = opts
      return function() calls.path_called = true end
    end,
  }
  local utils = {}
  utils.build_provider = function(opts, provider) return opts and { provider = provider, opts = opts } or false end
  utils.setup_providers = function(opts, names)
    for index, name in ipairs(names) do
      opts[index] = utils.build_provider(opts[name], name)
    end
    return opts
  end
  utils.pad_string = function() return "" end
  utils.surround = function(_, _, children, condition)
    calls.virtual_env_condition = condition
    return children
  end
  with_component({
    components = {
      breadcrumbs = { marker = "breadcrumb" },
      separated_path = { marker = "path" },
      virtual_env = { virtual_env = { conda = { enabled = true } }, surround = { separator = "right" } },
    },
    providers = { virtual_env = { conda = { ignore_base = true } } },
  }, {
    init = init,
    utils = utils,
    condition = {
      has_virtual_env = function(conda)
        calls.conda = conda
        return true
      end,
    },
  }, function(component)
    local breadcrumbs = component.breadcrumbs { extra = true }
    local path = component.separated_path { extra = true }
    component.virtual_env()
    breadcrumbs.init()
    path.init()

    assert.equals("breadcrumb", calls.breadcrumbs.marker)
    assert.is_true(calls.breadcrumbs.extra)
    assert.equals("path", calls.path.marker)
    assert.is_true(calls.path.extra)
    assert.is_true(calls.breadcrumbs_called)
    assert.is_true(calls.path_called)
    assert.is_true(calls.virtual_env_condition())
    assert.is_true(calls.conda.enabled)
    assert.is_true(calls.conda.ignore_base)
  end)
end

T["AUI-STATUS-COMPONENT-07 supports repeated factory calls"] = function()
  with_component(
    { components = { mode = { mode_text = false, paste = false, spell = false } }, providers = {} },
    nil,
    function(component)
      local first = component.mode()
      local second = component.mode()

      assert.equals("str:default", first[2].provider)
      assert.equals("str:default", second[2].provider)
    end
  )
end

return T
