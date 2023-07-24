local M = {}

M.config = require "astroui.config"

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Load custom highlights from user configuration",
    group = vim.api.nvim_create_augroup("astronvim_highlights", { clear = true }),
    callback = function()
      if vim.g.colors_name then
        for _, module in ipairs { "init", vim.g.colors_name } do
          for group, spec in pairs(M.config.highlights[module] or {}) do
            vim.api.nvim_set_hl(0, group, spec)
          end
        end
      end
      vim.api.nvim_exec_autocmds("User", { pattern = "AstroColorScheme", modeline = false })
    end,
  })

  local colorscheme = M.config.colorscheme
  if colorscheme and not pcall(vim.cmd.colorscheme, colorscheme) then
    vim.notify(("Error setting up colorscheme: `%s`"):format(colorscheme), vim.log.levels.ERROR, { title = "AstroUI" })
  end
end

--- Get an icon from the AstroNvim internal icons if it is available and return it
---@param kind string The kind of icon in astroui.icons to retrieve
---@param padding? integer Padding to add to the end of the icon
---@param no_fallback? boolean Whether or not to disable fallback to text icon
---@return string icon
function M.get_icon(kind, padding, no_fallback)
  if not M.config.icons_enabled and no_fallback then return "" end
  local icon_pack = M.config[M.config.icons_enabled and "icons" or "text_icons"]
  local icon = icon_pack[kind]
  return icon and icon .. string.rep(" ", padding or 0) or ""
end

--- Get a icon spinner table if it is available in the AstroNvim icons. Icons in format `kind1`,`kind2`, `kind3`, ...
---@param kind string The kind of icon to check for sequential entries of
---@return string[]|nil spinners # A collected table of spinning icons in sequential order or nil if none exist
function M.get_spinner(kind, ...)
  local spinner = {}
  repeat
    local icon = M.get_icon(("%s%d"):format(kind, #spinner + 1), ...)
    if icon ~= "" then table.insert(spinner, icon) end
  until not icon or icon == ""
  if #spinner > 0 then return spinner end
end

return M
