local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function extend_tbl(defaults, options) return vim.tbl_deep_extend("force", vim.deepcopy(defaults), options or {}) end

local function with_init(options, callback)
  options = options or {}
  local calls = options.calls or {}
  local loaded = vim.tbl_extend("force", {
    astrocore = { extend_tbl = extend_tbl },
    astroui = {
      config = {
        status = {
          separators = { breadcrumbs = " / ", path = " / " },
          icon_highlights = { breadcrumbs = "BreadcrumbIcon" },
        },
      },
      get_icon = function(name) return "<" .. name .. ">" end,
    },
    ["astroui.status.provider"] = {
      unique_path = function()
        return function() return "" end
      end,
    },
    ["astroui.status.utils"] = {
      pad_string = function(_, padding) return ("pad:%d:%d"):format(padding.left or 0, padding.right or 0) end,
    },
    aerial = {
      get_location = function()
        local location = table.remove(calls.locations or {}, 1)
        return location or {}
      end,
    },
  }, options.loaded or {})
  return helpers.with_module(
    "astroui.status.init",
    { loaded = loaded, vim = options.vim },
    function(init) return callback(init, calls) end
  )
end

local function component(winnr)
  return {
    winnr = winnr,
    new = function(_, children, index) return { children = children, index = index } end,
  }
end

local function find_click(children)
  for _, child in ipairs(children) do
    if child.on_click then return child.on_click end
    if type(child) == "table" then
      local nested = find_click(child)
      if nested then return nested end
    end
  end
end

T["AUI-STATUS-INIT-01 builds bounded breadcrumbs with prefix icons separators and padding"] = function()
  local calls = {}
  with_init({
    calls = calls,
    vim = {
      fn = {
        win_getid = function(winnr) return winnr + 100 end,
        hlexists = function(group) return group == "AerialClassIcon" and 1 or 0 end,
      },
    },
  }, function(init)
    calls.locations = {
      {
        { name = "root", kind = "Function", icon = "R", lnum = 1, col = 0 },
        { name = "parent", kind = "Function", icon = "P", lnum = 2, col = 1 },
        { name = "child% -> name", kind = "Class", icon = "C", lnum = 3, col = 2 },
        { name = "leaf", kind = "Method", icon = "L", lnum = 4, col = 3 },
      },
    }
    local self = component(1)
    init.breadcrumbs {
      max_depth = 2,
      prefix = true,
      padding = { left = 2, right = 3 },
      icon = { enabled = true, hl = function() return "BreadcrumbIcon" end },
    }(self)

    local children = self[1].children
    assert.equals("pad:1:0", children[1].provider)
    assert.equals(" / ", children[2].provider)
    assert.equals("<Ellipsis> / ", children[3].provider)
    assert.equals("C ", children[4][1].provider)
    assert.equals("AerialClassIcon", children[4][1].hl)
    assert.equals("child%%name", children[4][2].provider)
    assert.equals(" / ", children[4][3].provider)
    assert.equals("L ", children[5][1].provider)
    assert.is_nil(children[5][1].hl)
    assert.equals("leaf", children[5][2].provider)
    assert.equals("pad:0:2", children[6].provider)
  end)
end

T["AUI-STATUS-INIT-02 gives breadcrumb instances unique clicks and isolates window positions"] = function()
  local calls, cursor_calls = {}, {}
  with_init({
    calls = calls,
    vim = {
      fn = {
        win_getid = function(winnr) return ({ [1] = 101, [2] = 202 })[winnr] end,
        hlexists = function() return 0 end,
      },
      api = {
        nvim_win_is_valid = function(winid) return winid == 101 end,
        nvim_win_set_cursor = function(winid, position) table.insert(cursor_calls, { winid, position }) end,
      },
    },
  }, function(init)
    local first = init.breadcrumbs { icon = { enabled = false } }
    local second = init.breadcrumbs { icon = { enabled = false } }
    calls.locations = {
      { { name = "first", lnum = 7, col = 4 } },
      { { name = "second", lnum = 9, col = 2 } },
    }
    local first_self, second_self = component(1), component(2)
    first(first_self)
    second(second_self)

    local first_click = find_click(first_self[1].children)
    local second_click = find_click(second_self[1].children)
    assert.not_equals(first_click.name, second_click.name)

    first_click.callback(nil, 1)
    second_click.callback(nil, 1)
    assert.equals(1, #cursor_calls)
    assert.equals(101, cursor_calls[1][1])
    assert.same({ 7, 4 }, cursor_calls[1][2])
  end)
end

T["AUI-STATUS-INIT-03 separates POSIX and Windows paths with configured bounds"] = function()
  local calls = {}
  with_init({
    calls = calls,
    vim = {
      fn = {
        has = function(feature) return feature == "win32" and 0 or 0 end,
        split = function(path, delimiter)
          table.insert(calls.splits, { path, delimiter })
          return { "root", "one", "two", "leaf" }
        end,
      },
    },
  }, function(init)
    calls.splits = {}
    local posix = component(1)
    init.separated_path {
      path_func = function() return "root/one/two/leaf" end,
      max_depth = 2,
      prefix = true,
      padding = { left = 2, right = 2 },
    }(posix)
    local children = posix[1].children
    assert.equals("/", calls.splits[1][2])
    assert.equals("pad:1:0", children[1].provider)
    assert.equals(" / ", children[2].provider)
    assert.equals("<Ellipsis> / ", children[3].provider)
    assert.equals("two", children[4][1].provider)
    assert.equals(" / ", children[4][2].provider)
    assert.equals("leaf", children[5][1].provider)
    assert.equals(" / ", children[5][2].provider)
    assert.equals("pad:0:1", children[6].provider)

    local windows = component(1)
    init.separated_path {
      path_func = function() return "C:\\work\\file" end,
      delimiter = "\\",
      max_depth = 0,
      suffix = false,
    }(windows)
    assert.equals("\\", calls.splits[2][2])
    assert.equals("root", windows[1].children[1][1].provider)
    assert.is_nil(windows[1].children[4][2])
  end)
end

T["AUI-STATUS-INIT-04 suppresses empty path prefixes while retaining requested padding"] = function()
  local calls = {}
  with_init({
    calls = calls,
    vim = {
      fn = {
        has = function() return 0 end,
        split = function(path)
          assert.equals("", path)
          return {}
        end,
      },
    },
  }, function(init)
    local self = component(1)
    init.separated_path {
      path_func = function() return "." end,
      prefix = true,
      suffix = true,
      padding = { left = 1, right = 1 },
    }(self)
    assert.equals(2, #self[1].children)
    assert.equals("pad:0:0", self[1].children[1].provider)
    assert.equals("pad:0:0", self[1].children[2].provider)
  end)
end

T["AUI-STATUS-INIT-05 dispatches normalized update event forms"] = function()
  local autocmds = {}
  with_init({
    vim = {
      api = {
        nvim_create_autocmd = function(event, options)
          local key = event .. ":" .. (options.pattern or "")
          autocmds[key] = autocmds[key] or {}
          table.insert(autocmds[key], options.callback)
        end,
      },
    },
  }, function(init)
    local string_init = init.update_events "BufEnter"
    local table_init = init.update_events { "User", pattern = "LspProgressUpdate" }
    local list_init = init.update_events {
      "BufWinEnter",
      {
        "User",
        pattern = "AstroFile",
        callback = function(instance, args) instance.callback_args = args end,
      },
    }
    local string_cache_clears = 0
    local string_instance = setmetatable({}, {
      __index = function(_, key)
        if key == "_win_cache" then return {} end
      end,
      __newindex = function(target, key, value)
        if key == "_win_cache" and value == nil then
          string_cache_clears = string_cache_clears + 1
        else
          rawset(target, key, value)
        end
      end,
    })
    local table_instance = { _win_cache = {} }
    local list_instance = { _win_cache = {} }
    string_init(string_instance)
    string_init(string_instance)
    table_init(table_instance)
    list_init(list_instance)

    local args = { match = "AstroFile" }
    for _, callback in ipairs(autocmds["BufEnter:"]) do
      callback(args)
    end
    for _, callback in ipairs(autocmds["User:LspProgressUpdate"]) do
      callback(args)
    end
    for _, callback in ipairs(autocmds["BufWinEnter:"]) do
      callback(args)
    end
    for _, callback in ipairs(autocmds["User:AstroFile"]) do
      callback(args)
    end
    assert.equals(1, string_cache_clears)
    assert.is_nil(table_instance._win_cache)
    assert.is_nil(list_instance._win_cache)
    assert.equals(args, list_instance.callback_args)
  end)
end

T["AUI-STATUS-INIT-06 update event cleanup callbacks release weak instances"] = function()
  local autocmd
  with_init({
    vim = {
      api = {
        nvim_create_autocmd = function(_, options) autocmd = options end,
      },
    },
  }, function(init)
    local initialize = init.update_events "BufEnter"
    do
      local instance = { _win_cache = {} }
      initialize(instance)
    end
    collectgarbage "collect"
    collectgarbage "collect"
    assert.is_true(autocmd.callback {})
  end)
end

return T
