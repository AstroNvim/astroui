local M = {}
M.remove = {}

function M.with_module(module_name, options, callback)
  options = options or {}
  local names = { [module_name] = true }
  for name in pairs(options.loaded or {}) do
    names[name] = true
  end
  for name in pairs(options.preload or {}) do
    names[name] = true
  end
  local packages = {}
  for name in pairs(names) do
    packages[name] = { loaded = package.loaded[name], preload = package.preload[name] }
  end
  local fields = {}
  local function replace(target, changes)
    for name, value in pairs(changes or {}) do
      if type(value) == "table" and type(target[name]) == "table" then
        replace(target[name], value)
      else
        table.insert(fields, { target = target, name = name, value = target[name] })
        target[name] = value
      end
    end
  end
  local scheduled = {}
  local original_notify = vim.notify
  local original_schedule = vim.schedule
  local context = {}
  function context.drain()
    local errors = {}
    while #scheduled > 0 do
      local callbacks = scheduled
      scheduled = {}
      for _, callback_fn in ipairs(callbacks) do
        local ok, error_message = xpcall(callback_fn, debug.traceback)
        if not ok then table.insert(errors, error_message) end
      end
    end
    if #errors > 0 then error(table.concat(errors, "\n"), 0) end
  end
  local ok, result = xpcall(function()
    for name, value in pairs(options.loaded or {}) do
      if value == M.remove then
        package.loaded[name] = nil
      else
        package.loaded[name] = value
      end
    end
    for name, value in pairs(options.preload or {}) do
      if value == M.remove then
        package.preload[name] = nil
      else
        package.preload[name] = value
      end
    end
    package.loaded[module_name] = nil
    replace(vim, options.vim)
    vim.notify = options.notify or function() end
    vim.schedule = function(callback_fn) table.insert(scheduled, callback_fn) end

    return callback(require(module_name), context)
  end, debug.traceback)
  local cleanup_errors = {}
  local function cleanup(callback_fn)
    local cleanup_ok, cleanup_error = xpcall(callback_fn, debug.traceback)
    if not cleanup_ok then table.insert(cleanup_errors, cleanup_error) end
  end
  cleanup(context.drain)
  cleanup(function() vim.schedule = original_schedule end)
  cleanup(function() vim.notify = original_notify end)
  cleanup(function()
    for index = #fields, 1, -1 do
      local field = fields[index]
      field.target[field.name] = field.value
    end
  end)
  cleanup(function()
    for name, package_state in pairs(packages) do
      package.loaded[name] = package_state.loaded
      package.preload[name] = package_state.preload
    end
  end)
  if not ok then
    if #cleanup_errors > 0 then result = result .. "\nCleanup failed: " .. table.concat(cleanup_errors, "\n") end
    error(result, 0)
  end
  if #cleanup_errors > 0 then error(table.concat(cleanup_errors, "\n"), 0) end
  return result
end

return M
