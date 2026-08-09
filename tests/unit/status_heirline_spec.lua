local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_heirline(options, callback)
  options = options or {}
  local calls = options.calls or {}
  local loaded = vim.tbl_extend("force", {
    astroui = {
      config = { status = { setup_colors = { normal = "#ffffff" } } },
      get_icon = function(name) return "<" .. name .. ">" end,
    },
    ["astroui.status.hl"] = {
      get_attributes = function(name) return { name = name } end,
    },
    ["astroui.status.provider"] = {
      filename = function()
        return function(self) return self.filename end
      end,
      str = function(provider_options) return "[" .. provider_options.str .. "]" end,
    },
    ["astroui.status.utils"] = {
      surround = function(_, _, children) return children end,
    },
    ["astrocore.buffer"] = {
      is_valid = function(bufnr) return bufnr > 0 end,
    },
    ["heirline.utils"] = {
      make_buflist = function(...) return { ... } end,
      make_tablist = function(...) return { ... } end,
      on_colorscheme = function() end,
    },
    heirline = { tabline = {} },
  }, options.loaded or {})
  return helpers.with_module(
    "astroui.status.heirline",
    { loaded = loaded, vim = options.vim },
    function(heirline) return callback(heirline, calls) end
  )
end

T["AUI-STATUS-HEIRLINE-01 reports active visible and neutral tab types"] = function()
  with_heirline(nil, function(heirline)
    assert.equals("buffer_active", heirline.tab_type { is_active = true, is_visible = true })
    assert.equals("tab_visible", heirline.tab_type({ is_visible = true }, "tab"))
    assert.equals("buffer", heirline.tab_type {})
  end)
end

T["AUI-STATUS-HEIRLINE-02 hands off the exact five make_buflist arguments"] = function()
  local calls, switched = {}, {}
  with_heirline({
    calls = calls,
    loaded = {
      ["astroui.status.utils"] = {
        surround = function(...)
          calls.surround = { ... }
          return select(3, ...)
        end,
      },
      ["heirline.utils"] = {
        make_buflist = function(...)
          calls.arguments = { ... }
          return { built = true }
        end,
      },
    },
    vim = {
      api = {
        nvim_win_set_buf = function(window, bufnr) table.insert(switched, { window, bufnr }) end,
      },
    },
  }, function(heirline)
    local result = heirline.make_buflist { provider = "buffer" }
    local arguments = calls.arguments
    local buffer = arguments[1]

    assert.is_true(result.built)
    assert.equals(5, #arguments)
    assert.equals("<ArrowLeft> ", arguments[2].provider)
    assert.equals("<ArrowRight> ", arguments[3].provider)
    assert.is_false(arguments[5])
    assert.equals("tab", calls.surround[1])
    assert.equals(buffer, calls.surround[3])

    local buffer_instance = { is_active = true }
    buffer.init(buffer_instance)
    assert.equals("buffer_active", buffer_instance.tab_type)
    assert.equals("buffer_active_bg", calls.surround[2]({ is_active = true }).main)
    buffer.on_click.callback(nil, 27)
    assert.same({ { 0, 27 } }, switched)
    assert.equals(27, buffer.on_click.minwid { bufnr = 27 })
  end)
end

T["AUI-STATUS-HEIRLINE-03 filters local tab buffers and exposes overflow providers"] = function()
  local calls = {}
  with_heirline({
    calls = calls,
    loaded = {
      ["astrocore.buffer"] = { is_valid = function(bufnr) return bufnr % 2 == 0 end },
      ["heirline.utils"] = {
        make_buflist = function(...) calls.arguments = { ... } end,
      },
    },
  }, function(heirline)
    heirline.make_buflist { provider = "buffer" }
    local original = vim.t.bufs
    vim.t.bufs = { 1, 2, 3, 4 }
    local buffers = calls.arguments[4]()

    assert.same({ 2, 4 }, buffers)
    assert.same({ 2, 4 }, vim.t.bufs)
    vim.t.bufs = original
    assert.equals("<ArrowLeft> ", calls.arguments[2].provider)
    assert.equals("<ArrowRight> ", calls.arguments[3].provider)
  end)
end

T["AUI-STATUS-HEIRLINE-04 assigns unique picker labels for duplicates empties and exhaustion"] = function()
  local calls = {}
  with_heirline({
    calls = calls,
    loaded = {
      ["heirline.utils"] = {
        make_buflist = function(...) calls.buffer = select(1, ...) end,
      },
    },
  }, function(heirline)
    heirline.make_buflist { provider = "buffer" }
    local picker = calls.buffer[1]
    local labels = {}
    local first = { _picker_labels = labels, bufnr = 1, filename = "same.lua" }
    local second = { _picker_labels = labels, bufnr = 2, filename = "same.lua" }
    local empty = { _picker_labels = labels, bufnr = 3, filename = "" }
    picker.init(first)
    picker.init(second)
    picker.init(empty)

    assert.equals("s", first.label)
    assert.equals("a", second.label)
    assert.not_equals(first.label, second.label)
    assert.equals("1", empty.label)
    assert.equals(1, labels.s)
    assert.equals(2, labels.a)
    assert.equals(3, labels["1"])
    assert.equals("[1]", picker.provider(empty))

    local all_labels = {}
    for label in ("1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch "." do
      all_labels[label] = 99
    end
    all_labels.s, all_labels.a, all_labels.m, all_labels.e = 99, 99, 99, 99
    local exhausted = { _picker_labels = all_labels, bufnr = 4, filename = "same" }
    picker.init(exhausted)
    assert.is_nil(exhausted.label)
    assert.equals("", picker.provider(exhausted))
  end)
end

T["AUI-STATUS-HEIRLINE-05 caches non-nil highlights per wrapper and keeps cached functions dynamic"] = function()
  local calls = { highlights = {} }
  with_heirline({
    calls = calls,
    loaded = {
      ["astroui.status.hl"] = {
        get_attributes = function(name)
          calls.highlights[name] = (calls.highlights[name] or 0) + 1
          if name == "buffer_picker" then
            return function(self) return "picker-" .. self.id end
          end
          return { name = name, call = calls.highlights[name] }
        end,
      },
      ["heirline.utils"] = {
        make_buflist = function(...)
          calls.handoffs = calls.handoffs or {}
          table.insert(calls.handoffs, { ... })
        end,
      },
    },
  }, function(heirline)
    heirline.make_buflist { provider = "one" }
    heirline.make_buflist { provider = "two" }
    local first, second = calls.handoffs[1], calls.handoffs[2]

    assert.equals("buffer_overflow", first[2].hl({}).name)
    assert.equals("buffer_overflow", first[2].hl({}).name)
    assert.equals("buffer_overflow", second[2].hl({}).name)
    assert.equals(2, calls.highlights.buffer_overflow)
    assert.equals("picker-first", first[1][1].hl { id = "first" })
    assert.equals("picker-second", first[1][1].hl { id = "second" })
    assert.equals(1, calls.highlights.buffer_picker)
  end)
end

T["AUI-STATUS-HEIRLINE-06 delegates tab list construction and color refresh"] = function()
  local calls = {}
  with_heirline({
    calls = calls,
    loaded = {
      ["heirline.utils"] = {
        make_tablist = function(...)
          calls.tablist = { ... }
          return "tabs"
        end,
        on_colorscheme = function(colors) calls.colors = colors end,
      },
    },
  }, function(heirline)
    assert.equals("tabs", heirline.make_tablist("component", "extra"))
    heirline.refresh_colors()
    assert.same({ "component", "extra" }, calls.tablist)
    assert.same({ normal = "#ffffff" }, calls.colors)
  end)
end

local function picker_scenario(failure, expected_error)
  local calls = { redraws = 0, callback = 0 }
  local buflist = { _picker_labels = { x = 42 } }
  local previous_showtabline = vim.o.showtabline
  vim.o.showtabline = 1
  with_heirline({
    calls = calls,
    loaded = { heirline = { tabline = { _buflist = { buflist } } } },
    vim = {
      cmd = {
        redrawtabline = function()
          calls.redraws = calls.redraws + 1
          if failure == "first redraw" and calls.redraws == 1 then error(expected_error) end
          if calls.redraws == 2 then buflist._picker_labels.x = 42 end
          if failure == "second redraw" and calls.redraws == 2 then error(expected_error) end
        end,
      },
      fn = {
        getcharstr = function()
          if failure == "input" then error(expected_error) end
          return "x"
        end,
      },
    },
  }, function(heirline)
    local ok, error_message = pcall(heirline.buffer_picker, function(bufnr)
      calls.callback = calls.callback + 1
      assert.equals(42, bufnr)
      if failure == "callback" then error(expected_error) end
    end)
    if failure then
      assert.is_false(ok)
      assert.matches(expected_error, error_message)
    else
      assert.is_true(ok)
      assert.equals(1, calls.callback)
    end
    assert.is_false(buflist._show_picker or false)
    assert.equals(1, vim.o.showtabline)
    assert.is_true(calls.redraws >= 2)
  end)
  vim.o.showtabline = previous_showtabline
end

T["AUI-STATUS-HEIRLINE-07 runs a picker selection and ignores unmapped input"] = function()
  picker_scenario(nil, "")

  local calls = { redraws = 0, callback = 0 }
  local buflist = { _picker_labels = {} }
  with_heirline({
    calls = calls,
    loaded = { heirline = { tabline = { _buflist = { buflist } } } },
    vim = {
      cmd = { redrawtabline = function() calls.redraws = calls.redraws + 1 end },
      fn = { getcharstr = function() return "?" end },
    },
  }, function(heirline)
    heirline.buffer_picker(function() calls.callback = calls.callback + 1 end)
    assert.equals(0, calls.callback)
    assert.is_false(buflist._show_picker)
  end)
end

T["AUI-STATUS-HEIRLINE-08 leaves a missing buffer list unchanged"] = function()
  local calls = { redraws = 0, callback = 0 }
  local previous_showtabline = vim.o.showtabline
  vim.o.showtabline = 1
  with_heirline({
    calls = calls,
    loaded = { heirline = { tabline = {} } },
    vim = { cmd = { redrawtabline = function() calls.redraws = calls.redraws + 1 end } },
  }, function(heirline)
    heirline.buffer_picker(function() calls.callback = calls.callback + 1 end)
    assert.equals(0, calls.callback)
    assert.equals(2, calls.redraws)
    assert.equals(1, vim.o.showtabline)
  end)
  vim.o.showtabline = previous_showtabline
end

T["AUI-STATUS-HEIRLINE-09 rolls picker state back after each operational failure"] = function()
  picker_scenario("first redraw", "first redraw failed")
  picker_scenario("second redraw", "second redraw failed")
  picker_scenario("input", "input failed")
  picker_scenario("callback", "callback failed")
end

return T
