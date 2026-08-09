local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function extend_tbl(defaults, options)
  return vim.tbl_deep_extend("force", vim.deepcopy(defaults or {}), options or {})
end

local function with_utils(options, callback)
  options = options or {}
  return helpers.with_module("astroui.status.utils", {
    loaded = vim.tbl_extend("force", {
      astrocore = { extend_tbl = extend_tbl },
      astroui = {
        config = { status = { separators = { named = { "<", ">" } } } },
        get_icon = function(kind) return "[" .. kind .. "]" end,
        get_hlgroup = function() return {} end,
      },
      ["astroui.status.init"] = {
        update_events = function(events)
          return function() return events end
        end,
      },
    }, options.loaded or {}),
    preload = options.preload,
  }, callback)
end

local function with_fake_vim(fake, callback)
  local original = _G.vim
  _G.vim = fake
  local ok, result = xpcall(callback, debug.traceback)
  _G.vim = original
  if not ok then error(result, 0) end
  return result
end

local function icon_vim()
  return {
    fn = { fnamemodify = function(path) return path:match "[^/]+$" or path end },
    api = { nvim_buf_get_name = function() return "/work/example.lua" end },
    bo = { [0] = { filetype = "lua", buftype = "" } },
  }
end

T["AUI-STATUS-UTILS-01 builds providers and preserves explicit false"] = function()
  with_utils(nil, function(utils)
    local opts = {
      condition = false,
      on_click = "click",
      update = { "BufEnter" },
      hl = { fg = "red" },
    }
    local provider = utils.build_provider(opts, "filename")

    assert.equals("filename", provider.provider)
    assert.equals(opts, provider.opts)
    assert.is_false(provider.condition)
    assert.equals("click", provider.on_click)
    assert.same({ "BufEnter" }, provider.update)
    assert.same({ fg = "red" }, provider.hl)
    assert.is_false(utils.build_provider(false, "filename"))
    assert.is_false(utils.build_provider(nil, "filename"))
  end)
end

T["AUI-STATUS-UTILS-02 sets providers in declared order and owns numeric slots"] = function()
  with_utils(nil, function(utils)
    local opts = { first = { value = 1 }, second = false, [1] = "stale", [2] = "old" }
    local calls = {}
    local result = utils.setup_providers(opts, { "second", "first" }, function(provider_opts, name, index)
      table.insert(calls, { provider_opts, name, index })
      return name .. ":" .. index
    end)

    assert.equals(opts, result)
    assert.same({ { false, "second", 1 }, { opts.first, "first", 2 } }, calls)
    assert.equals("second:1", opts[1])
    assert.equals("first:2", opts[2])
  end)
end

T["AUI-STATUS-UTILS-03 resolves statusline and winbar widths"] = function()
  with_utils(nil, function(utils)
    with_fake_vim(
      { o = { laststatus = 3, columns = 180 }, api = { nvim_win_get_width = function() return 91 end } },
      function()
        assert.equals(180, utils.width())
        assert.equals(91, utils.width(true))
      end
    )
    with_fake_vim(
      { o = { laststatus = 2, columns = 180 }, api = { nvim_win_get_width = function() return 91 end } },
      function() assert.equals(91, utils.width()) end
    )
  end)
end

T["AUI-STATUS-UTILS-04 pads and stylizes defaults escaping icons separators and empties"] = function()
  with_utils({
    loaded = {
      astroui = {
        config = { status = { separators = { named = { "<", ">" } } } },
        get_icon = function(kind) return kind == "File" and "I" or "" end,
        get_hlgroup = function() return {} end,
      },
    },
  }, function(utils)
    assert.equals("  text ", utils.pad_string("text", { left = 2, right = 1 }))
    assert.equals("", utils.pad_string("", { left = 2, right = 1 }))
    assert.equals("", utils.pad_string(nil, { left = 2, right = 1 }))
    assert.equals("text", utils.stylize "text")
    assert.equals(
      "< I value%% >",
      utils.stylize("value%", {
        icon = { kind = "File", padding = { right = 1 } },
        padding = { left = 1, right = 1 },
        separator = { left = "<", right = ">" },
      })
    )
    assert.equals("value%", utils.stylize("value%", { escape = false }))
    assert.equals(
      "<>",
      utils.stylize("", {
        show_empty = true,
        padding = { left = 2 },
        separator = { left = "<", right = ">" },
      })
    )
    assert.equals("", utils.stylize("", { separator = { left = "<", right = ">" } }))
  end)
end

T["AUI-STATUS-UTILS-05 surrounds named and raw separators with dynamic highlights"] = function()
  with_utils({
    loaded = {
      ["astroui.status.init"] = {
        update_events = function(events)
          return function() return "updated:" .. events[1] end
        end,
      },
    },
  }, function(utils)
    local component = { provider = "body", hl = { fg = "white" } }
    local surrounded = utils.surround(
      "named",
      function(self) return { main = self.main, left = "left", right = "right" } end,
      component,
      function() return true end,
      { "BufEnter" }
    )

    assert.equals(3, #surrounded)
    assert.is_function(surrounded.condition)
    assert.equals("<", surrounded[1].provider)
    assert.same({ fg = "blue", bg = "left" }, surrounded[1].hl { main = "blue" })
    assert.equals("body", surrounded[2].provider)
    assert.same({ fg = "white", bg = "blue" }, surrounded[2].hl { main = "blue" })
    assert.equals(">", surrounded[3].provider)
    assert.same({ fg = "blue", bg = "right" }, surrounded[3].hl { main = "blue" })
    assert.is_false(surrounded[3].update())
    assert.equals("updated:BufEnter", surrounded[3].init())

    local functional = { provider = "raw", hl = function() return { bold = true } end }
    local raw = utils.surround({ "", ")" }, { main = "green", right = "black" }, functional, true)
    assert.equals(2, #raw)
    assert.same({ bold = true, bg = "green" }, raw[1].hl())
    assert.same({ fg = "green", bg = "black" }, raw[2].hl())
    assert.is_function(raw[2].update)
  end)
end

T["AUI-STATUS-UTILS-06 prefers MiniIcons and converts numeric highlights"] = function()
  local original_mini = _G.MiniIcons
  _G.MiniIcons = true
  local ok, result = xpcall(function()
    with_utils({
      loaded = {
        ["mini.icons"] = {
          get = function(category, value)
            if category == "file" then return "F", "MiniFile", true end
            assert.equals("filetype", category)
            assert.equals("lua", value)
            return "L", "MiniLua", false
          end,
        },
        astroui = {
          config = { status = { separators = { named = { "<", ">" } } } },
          get_icon = function() return "" end,
          get_hlgroup = function(group) return { fg = group == "MiniLua" and 0x0abcde or nil } end,
        },
      },
    }, function(utils)
      with_fake_vim(icon_vim(), function() assert.same({ "L", "#0abcde" }, { utils.icon_provider() }) end)
    end)
  end, debug.traceback)
  _G.MiniIcons = original_mini
  if not ok then error(result, 0) end
end

T["AUI-STATUS-UTILS-07 falls back to devicons and retries after a cached miss"] = function()
  local original_mini = _G.MiniIcons
  _G.MiniIcons = nil
  local ok, result = xpcall(function()
    with_utils({
      preload = {
        ["mini.icons"] = function() error "missing MiniIcons" end,
        ["nvim-web-devicons"] = function() error "missing devicons" end,
      },
    }, function(utils)
      with_fake_vim(icon_vim(), function()
        assert.is_nil(utils.icon_provider())
        package.loaded["nvim-web-devicons"] = {
          get_icon_color = function() return "D", nil end,
          get_icon_color_by_filetype = function(filetype, opts)
            assert.equals("lua", filetype)
            assert.is_true(opts.default)
            return "L", "#123456"
          end,
        }
        assert.same({ "L", "#123456" }, { utils.icon_provider() })
      end)
    end)
  end, debug.traceback)
  _G.MiniIcons = original_mini
  if not ok then error(result, 0) end

  with_utils({
    preload = { ["mini.icons"] = function() error "missing MiniIcons" end },
  }, function(utils)
    with_fake_vim(icon_vim(), function()
      package.loaded["nvim-web-devicons"] = {
        get_icon_color = function() return "D", "#abcdef" end,
        get_icon_color_by_filetype = function() error "unexpected filetype fallback" end,
      }
      assert.same({ "D", "#abcdef" }, { utils.icon_provider() })
    end)
  end)
end

T["AUI-STATUS-UTILS-08 encodes boundaries and rejects malformed positions"] = function()
  with_utils(nil, function(utils)
    local encoded = utils.encode_pos(65535, 1023, 63)
    assert.same({ 65535, 1023, 63 }, { utils.decode_pos(encoded) })
    assert.same({ 0, 0, 0 }, { utils.decode_pos(utils.encode_pos(0, 0, 0)) })
    for _, invalid in ipairs { { -1, 0, 0 }, { 65536, 0, 0 }, { 0, 1.5, 0 }, { 0, 1024, 0 }, { 0, 0, 64 }, { "1", 0, 0 } } do
      assert.error(function() utils.encode_pos(unpack(invalid)) end)
    end
  end)
end

T["AUI-STATUS-UTILS-09 ranks signs by priority id placement and order"] = function()
  with_utils(nil, function(utils)
    assert.is_true(utils.sign_is_higher(nil, { priority = 0 }))
    assert.is_true(utils.sign_is_higher({ priority = 1 }, { priority = 2 }))
    assert.is_false(utils.sign_is_higher({ priority = 2 }, { priority = 1 }))
    assert.is_true(utils.sign_is_higher({ priority = 2, id = 3 }, { priority = 2, id = 4 }))
    assert.is_true(utils.sign_is_higher({ priority = 2, id = 4, rank = math.huge }, { priority = 2, id = 4, rank = 3 }))
    assert.is_true(utils.sign_is_higher({ priority = 2, id = 4, rank = 4 }, { priority = 2, id = 4, rank = 3 }))
    assert.is_true(
      utils.sign_is_higher({ priority = 2, id = 4, rank = 3, order = 1 }, { priority = 2, id = 4, rank = 3, order = 2 })
    )

    local low = { priority = 1, id = 1, rank = 2, order = 1 }
    local middle = { priority = 2, id = 1, rank = 2, order = 1 }
    local high = { priority = 2, id = 2, rank = 1, order = 1 }
    assert.is_true(utils.sign_is_higher(low, middle))
    assert.is_true(utils.sign_is_higher(middle, high))
    assert.is_true(utils.sign_is_higher(low, high))
  end)
end

T["AUI-STATUS-UTILS-10 normalizes namespaces placement ranks duplicates and number highlights"] = function()
  with_utils(nil, function(utils)
    local extmarks = {
      { 7, 0, 0, { ns_id = 10, sign_text = "A ", sign_name = "Named", priority = 20, number_hl_group = "Number" } },
      { 7, 0, 1, { ns_id = 10, sign_text = "B ", sign_name = "Named", priority = 10 } },
      { 8, 0, 2, { ns_id = 11, sign_text = "C ", sign_name = "Anonymous" } },
      { 9, 0, 3, { sign_text = "D ", sign_name = "Ungrouped" } },
    }
    local fake = {
      api = {
        nvim_get_namespaces = function() return { named_group = 10 } end,
        nvim_buf_get_extmarks = function() return extmarks end,
      },
      fn = {
        sign_getplaced = function()
          return { { signs = { { group = "named_group", id = 7 }, { group = "named_group", id = 7 } } } }
        end,
      },
    }
    with_fake_vim(fake, function()
      local signs = utils.get_signs(3, 0)
      assert.equals("named_group", signs[1].namespace)
      assert.is_false(signs[1].anonymous)
      assert.equals(1, signs[1].rank)
      assert.equals(2, signs[2].rank)
      assert.equals("Number", signs[1].number_hl_group)
      assert.equals("#11", signs[3].namespace)
      assert.is_true(signs[3].anonymous)
      assert.equals(math.huge, signs[3].rank)
      assert.equals("", signs[4].namespace)
      assert.is_false(signs[4].anonymous)
      assert.equals(4, signs[4].order)
    end)
  end)
end

T["AUI-STATUS-UTILS-11 groups active null-ls sources and maps public methods"] = function()
  with_utils({
    preload = {
      ["null-ls.sources"] = function()
        return {
          get_available = function(filetype)
            assert.equals("lua", filetype)
            return {
              { name = "format", methods = { formatting = true } },
              {
                name = "disabled",
                methods = { formatting = true },
                generator = { source_id = 3, opts = { runtime_condition = function() return false end } },
              },
              {
                name = "erroring",
                methods = { diagnostics = true },
                generator = { source_id = 4, opts = { runtime_condition = function() error "runtime failed" end } },
              },
            }
          end,
        }
      end,
      ["null-ls.methods"] = function() return { internal = { FORMATTING = "formatting", DIAGNOSTICS = "diagnostics" } } end,
    },
  }, function(utils)
    local params = { filetype = "lua" }
    assert.same({ "format" }, utils.null_ls_providers(params).formatting)
    assert.same({ "erroring" }, utils.null_ls_providers({ filetype = "lua" }).diagnostics)
    assert.same({ "format" }, utils.null_ls_sources { filetype = "lua", method = "FORMATTING" })
  end)

  with_utils({
    preload = {
      ["null-ls.sources"] = function() error "unavailable" end,
      ["null-ls.methods"] = function() error "unavailable" end,
    },
  }, function(utils)
    assert.same({}, utils.null_ls_providers { filetype = "lua" })
    assert.same({}, utils.null_ls_sources { filetype = "lua", method = "FORMATTING" })
  end)
end

local function click_vim(state)
  return {
    fn = {
      getmousepos = function() return state.mousepos end,
      screenstring = function(_, column) return state.characters[column] or " " end,
      strchars = function(text) return #text end,
      strcharpart = function(text, index) return text:sub(index + 1, index + 1) end,
      getwininfo = function() return { { textoff = state.textoff } } end,
    },
    api = {
      nvim_win_get_buf = function() return 21 end,
      nvim_set_current_win = function(window) state.current_window = window end,
      nvim_win_set_cursor = function(_, cursor) state.cursor = cursor end,
    },
    wo = { [4] = { signcolumn = state.signcolumn } },
  }
end

local function sign(text, priority, id, extra)
  return vim.tbl_extend("force", {
    sign_text = text,
    sign_name = "AUI" .. text,
    sign_hl_group = "AuiSign",
    priority = priority,
    id = id,
    order = id,
    rank = id,
  }, extra or {})
end

local function click_args(utils, state, signs)
  utils.get_signs = function() return signs end
  local self = {}
  local args
  with_fake_vim(click_vim(state), function() args = utils.statuscolumn_clickargs(self, 8, 2, "l", "c") end)
  return args, self
end

T["AUI-STATUS-UTILS-12 decodes click characters priorities slots modifiers and window state"] = function()
  with_utils(nil, function(utils)
    local state = {
      signcolumn = "yes:2",
      textoff = 10,
      mousepos = { winid = 4, line = 6, screenrow = 3, screencol = 8, wincol = 7 },
      characters = { [8] = "B", [7] = "B" },
    }
    local args, self = click_args(utils, state, { sign("A ", 10, 1), sign("BC", 20, 2) })
    assert.equals("B", args.char)
    assert.equals("BC", args.sign.text)
    assert.equals("c", args.mods)
    assert.equals(21, self.bufnr)
    assert.equals(4, state.current_window)
    assert.same({ 6, 0 }, state.cursor)

    state.mousepos.wincol, state.mousepos.screencol = 9, 9
    state.characters[9] = "A"
    args = click_args(utils, state, { sign("A ", 10, 1), sign("BC", 20, 2) })
    assert.equals("A ", args.sign.text)

    state.mousepos.wincol, state.mousepos.screencol = 1, 9
    state.characters[9] = "BC"
    args = click_args(utils, state, { sign("A ", 10, 1), sign("BC", 20, 2) })
    assert.equals("BC", args.sign.text)

    state.mousepos.wincol, state.mousepos.screencol = 7, 8
    state.characters[8], state.characters[7] = " ", "A"
    args = click_args(utils, state, { sign("A ", 10, 1) })
    assert.equals("A", args.char)
    assert.equals("A ", args.sign.text)
  end)
end

T["AUI-STATUS-UTILS-13 maps every signcolumn geometry and leaves ambiguous signs unresolved"] = function()
  with_utils(nil, function(utils)
    local geometries = {
      yes = 1,
      number = 1,
      ["yes:3"] = 3,
      auto = 1,
      ["auto:2"] = 2,
      ["auto:2-3"] = 3,
    }
    for option, slots in pairs(geometries) do
      local signs = {}
      for index = 1, 4 do
        table.insert(signs, sign(string.char(64 + index) .. " ", 10 - index, index))
      end
      local start = 20 - slots * 2 + 1
      local state = {
        signcolumn = option,
        textoff = 20,
        mousepos = { winid = 4, line = 1, screenrow = 1, screencol = start, wincol = start },
        characters = { [start] = "A" },
      }
      local args = click_args(utils, state, signs)
      assert.equals("A ", args.sign.text, option)
    end

    local no_signs = {
      signcolumn = "auto",
      textoff = 20,
      mousepos = { winid = 4, line = 1, screenrow = 1, screencol = 20, wincol = 20 },
      characters = { [20] = " " },
    }
    assert.is_nil(click_args(utils, no_signs, {}).sign)

    local ambiguity = {
      signcolumn = "yes",
      textoff = 8,
      mousepos = { winid = 4, line = 1, screenrow = 1, screencol = 7, wincol = 7 },
      characters = { [7] = "X" },
    }
    local ambiguous = click_args(utils, ambiguity, {
      sign("X ", 10, 7, { anonymous = true, ns_id = 31 }),
      sign("X ", 10, 7, { anonymous = true, ns_id = 32 }),
    })
    assert.is_nil(ambiguous.sign)
  end)
end

return T
