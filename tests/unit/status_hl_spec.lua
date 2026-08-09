local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_hl(status_config, options, callback)
  options = options or {}
  local loaded = vim.tbl_extend("force", {
    astroui = { config = { status = status_config } },
    ["astroui.status.utils"] = { icon_provider = function() return "", nil end },
    ["heirline.highlights"] = { get_loaded_colors = function() return {} end },
  }, options.loaded or {})
  return helpers.with_module("astroui.status.hl", { loaded = loaded, vim = options.vim }, callback)
end

T["AUI-STATUS-HL-01 uses lualine colors and falls back when unavailable"] = function()
  local original_colors_name = vim.g.colors_name
  helpers.with_finalizer(function()
    vim.g.colors_name = nil
    with_hl(
      { attributes = {}, modes = {}, icon_highlights = {} },
      nil,
      function(hl) assert.equals("fallback", hl.lualine_mode("normal", "fallback")) end
    )
    vim.g.colors_name = "testtheme"
    with_hl({ attributes = {}, modes = {}, icon_highlights = {} }, {
      loaded = { ["lualine.themes.testtheme"] = { normal = { a = { bg = "#123456" } } } },
    }, function(hl)
      assert.equals("#123456", hl.lualine_mode("normal", "fallback"))
      assert.equals("fallback", hl.lualine_mode("insert", "fallback"))
    end)
  end, function() vim.g.colors_name = original_colors_name end)
end

T["AUI-STATUS-HL-02 returns mode and icon colors through their public helpers"] = function()
  with_hl({
    attributes = {},
    modes = { n = { "Normal", "mode_background" } },
    icon_highlights = {},
  }, {
    loaded = { ["astroui.status.utils"] = { icon_provider = function(bufnr) return "I", "#abcdef", bufnr end } },
    vim = { fn = { mode = function() return "n" end } },
  }, function(hl)
    assert.equals("mode_background", hl.mode_bg())
    assert.equals("mode_background", hl.mode().bg)
    assert.equals("#abcdef", hl.filetype_color({ bufnr = 17 }).fg)
  end)
end

T["AUI-STATUS-HL-03 returns loaded attributes and updates configured attributes"] = function()
  local configured = { bold = true }
  with_hl({ attributes = { status = configured }, modes = {}, icon_highlights = {} }, {
    loaded = {
      ["heirline.highlights"] = { get_loaded_colors = function() return { status_fg = true, status_bg = true } end },
    },
  }, function(hl)
    local attributes = hl.get_attributes("status", true)

    assert.equals("status_fg", attributes.fg)
    assert.equals("status_bg", attributes.bg)
    assert.is_true(configured.bold)
    assert.equals("status_fg", configured.fg)
    assert.equals("status_bg", configured.bg)
  end)
end

T["AUI-STATUS-HL-04 honors true, function, and false file icon highlight gates"] = function()
  local status_config = {
    attributes = {},
    modes = {},
    icon_highlights = {
      file_icon = { statusline = true, tabline = function(self) return self.enabled end, winbar = false },
    },
  }
  with_hl(status_config, {
    loaded = { ["astroui.status.utils"] = { icon_provider = function() return "I", "#ff00ff" end } },
  }, function(hl)
    assert.equals("#ff00ff", hl.file_icon "statusline"({ bufnr = 1 }).fg)
    assert.equals("#ff00ff", hl.file_icon "tabline"({ enabled = true }).fg)
    assert.is_nil(hl.file_icon "tabline" { enabled = false })
    assert.is_nil(hl.file_icon "winbar" {})
  end)
end

return T
