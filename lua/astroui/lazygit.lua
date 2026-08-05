--- Adapted from folke's snack.nvim lazygit integration:
--- https://github.com/folke/snacks.nvim/blob/14c787540828946126f2acb5e542dc57956c2711/lua/snacks/lazygit.lua
local M = {}

local astroui = require "astroui"
local config = astroui.config.lazygit

local function yaml_scalar(value)
  if type(value) == "string" then return vim.json.encode(value) end
  if type(value) == "number" or type(value) == "boolean" then return tostring(value) end
  if value == nil then return "null" end
  error(("Cannot serialize %s as YAML"):format(type(value)))
end

local function yaml_key(key)
  if type(key) == "number" then return tostring(key) end
  if key:match "^[%a_][%w_-]*$" then return key end
  return vim.json.encode(key)
end

local function yaml_keys(tbl)
  local keys = vim.tbl_keys(tbl)
  table.sort(keys, function(left, right) return tostring(left) < tostring(right) end)
  return keys
end

local function yaml_empty_collection(tbl) return vim.islist(tbl) and "[]" or "{}" end

local function to_yaml(value, indent)
  local lines = {}
  local padding = string.rep(" ", indent)
  if vim.islist(value) then
    for _, item in ipairs(value) do
      if type(item) ~= "table" then
        table.insert(lines, padding .. "- " .. yaml_scalar(item))
      elseif next(item) == nil then
        table.insert(lines, padding .. "- " .. yaml_empty_collection(item))
      else
        table.insert(lines, padding .. "-")
        vim.list_extend(lines, to_yaml(item, indent + 2))
      end
    end
  else
    for _, key in ipairs(yaml_keys(value)) do
      local item = value[key]
      if type(item) ~= "table" then
        table.insert(lines, padding .. yaml_key(key) .. ": " .. yaml_scalar(item))
      elseif next(item) == nil then
        table.insert(lines, padding .. yaml_key(key) .. ": " .. yaml_empty_collection(item))
      else
        table.insert(lines, padding .. yaml_key(key) .. ":")
        vim.list_extend(lines, to_yaml(item, indent + 2))
      end
    end
  end
  return lines
end

-- Build theme configuration file
function M.update_config()
  if not config then return end
  ---@type table<string, string[]>
  local theme = vim.empty_dict()

  -- Check if TUI is attached
  -- TODO: REMOVE WHEN DROPPING SUPPORT FOR NEOVIM v0.11
  local tui_attached = false
  for _, ui in ipairs(vim.api.nvim_list_uis()) do
    if ui.chan == 1 and ui.stdout_tty then
      tui_attached = true
      break
    end
  end

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
      -- numeric keys set terminal palette entries, which only a terminal can act on
      -- TODO: REMOVE io.write WHEN DROPPING SUPPORT FOR NEOVIM v0.11
      if tui_attached then pcall(vim.api.nvim_ui_send or io.write, ("\27]4;%d;%s\7"):format(k, color[1])) end
    else
      theme[k] = color
    end
  end

  local lg_config = vim.tbl_deep_extend("force", { gui = { theme = theme } }, config.config or {})
  vim.fn.writefile(to_yaml(lg_config, 0), config.theme_path)
end

function M.setup()
  if type(config) ~= "table" then return end

  if config.theme_path then
    if not vim.uv.fs_stat(config.theme_path) then vim.schedule(M.update_config) end

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
      callback = function() vim.schedule(M.update_config) end,
    })
  end
end

return M
