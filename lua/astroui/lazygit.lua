--- Adapted from folke's snack.nvim lazygit integration:
--- https://github.com/folke/snacks.nvim/blob/14c787540828946126f2acb5e542dc57956c2711/lua/snacks/lazygit.lua
local M = {}

local astroui = require "astroui"
local config = astroui.config.lazygit

-- Build theme configuration file
function M.update_config()
  if not config then return end
  ---@type table<string, string[]>
  local theme = {}

  for k, v in pairs(config.theme or {}) do
    local color = {}
    for _, c in ipairs { "fg", "bg" } do
      if v[c] then
        local hl_color = astroui.get_hlgroup(v[c] --[[ @as string ]])[c]
        if type(hl_color) == "number" then table.insert(color, string.format("#%06x", hl_color)) end
      end
    end
    for _, modifier in ipairs { "bold", "reverse", "underline", "strikethrough" } do
      if v[modifier] then table.insert(color, modifier) end
    end
    if type(k) == "number" then
      pcall(io.write, ("\27]4;%d;%s\7"):format(k, color[1]))
    else
      theme[k] = color
    end
  end

  local lg_config = vim.tbl_deep_extend("force", { gui = { theme = theme } }, config.config or {})

  local function yaml_val(val) return type(val) == "string" and not val:find "^\"'`" and ("%q"):format(val) or val end

  local function to_yaml(tbl, indent)
    indent = indent or 0
    local lines = {}
    for k, v in pairs(tbl) do
      table.insert(lines, string.rep(" ", indent) .. k .. (type(v) == "table" and ":" or ": " .. yaml_val(v)))
      if type(v) == "table" then
        if (vim.islist or vim.tbl_islist)(v) then
          for _, item in ipairs(v) do
            table.insert(lines, string.rep(" ", indent + 2) .. "- " .. yaml_val(item))
          end
        else
          vim.list_extend(lines, to_yaml(v, indent + 2))
        end
      end
    end
    return lines
  end
  vim.fn.writefile(to_yaml(lg_config), config.theme_path)
end

function M.setup()
  if type(config) ~= "table" then return end

  M.update_config()

  local lg_config_file = vim.env.LG_CONFIG_FILE --[[ @as string? ]]
  if not lg_config_file and vim.fn.executable "lazygit" == 1 then
    lg_config_file = require("astrocore").cmd({ "lazygit", "-cd" }, false)
    if lg_config_file then lg_config_file = vim.split(lg_config_file, "\n", { plain = true })[1] .. "/config.yml" end
  end
  lg_config_file = lg_config_file and lg_config_file .. "," or ""
  vim.env.LG_CONFIG_FILE = vim.fs.normalize(lg_config_file .. config.theme_path)

  vim.api.nvim_create_autocmd("User", {
    pattern = "AstroColorScheme",
    group = vim.api.nvim_create_augroup("astroui_lazygit", { clear = true }),
    desc = "Update lazygit theme configuration when changing colorscheme",
    callback = M.update_config,
  })
end

return M
