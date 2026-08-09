local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_folding(folding_config, options, callback)
  options = options or {}
  local loaded = vim.tbl_extend("force", {
    astroui = { config = { folding = folding_config } },
    astrocore = { notify = function() end },
  }, options.loaded or {})

  return helpers.with_module("astroui.folding", {
    loaded = loaded,
    preload = options.preload,
    vim = options.vim,
  }, callback)
end

local function setup_api(overrides)
  return vim.tbl_extend("force", {
    nvim_create_user_command = function() end,
    nvim_create_augroup = function() return 1 end,
    nvim_create_autocmd = function() end,
  }, overrides or {})
end

T["AUI-FOLD-ENABLED-01 accepts only an explicit boolean true"] = function()
  with_folding({ enabled = true }, nil, function(folding) assert.is_true(folding.is_enabled()) end)
  with_folding({ enabled = false }, nil, function(folding) assert.is_false(folding.is_enabled()) end)
  with_folding({ enabled = "true" }, nil, function(folding) assert.is_false(folding.is_enabled()) end)
end

T["AUI-FOLD-ENABLED-02 calls the configured predicate with the requested buffer"] = function()
  local current_buffer = 73
  local observed = {}
  with_folding({
    enabled = function(bufnr)
      table.insert(observed, bufnr)
      return bufnr == current_buffer
    end,
  }, {
    vim = { api = { nvim_get_current_buf = function() return current_buffer end } },
  }, function(folding)
    assert.is_true(folding.is_enabled())
    assert.is_false(folding.is_enabled(74))
  end)

  assert.same({ 73, 74 }, observed)
end

T["AUI-FOLD-REFRESH-01 ignores an invalid buffer"] = function()
  local client_queries = 0
  with_folding({ enabled = true, methods = { "lsp" } }, {
    vim = {
      api = { nvim_buf_is_valid = function() return false end },
      lsp = { get_clients = function() client_queries = client_queries + 1 end },
    },
  }, function(folding) folding.refresh(94) end)

  assert.equals(0, client_queries)
end

T["AUI-FOLD-REFRESH-02 tracks LSP folding support per buffer and removes stale support"] = function()
  local current_buffer = 11
  local supported = true
  local client = {
    supports_method = function() return supported end,
  }
  with_folding({ enabled = true, methods = { "lsp" } }, {
    vim = {
      api = setup_api {
        nvim_get_current_buf = function() return current_buffer end,
        nvim_buf_is_valid = function() return true end,
      },
      lsp = {
        get_clients = function(opts) return opts.bufnr == 11 and { client } or {} end,
        foldexpr = function() return "lsp-fold" end,
      },
    },
  }, function(folding)
    folding.refresh(11)
    assert.equals("lsp-fold", folding.foldexpr(1))

    current_buffer = 12
    assert.equals("0", folding.foldexpr(1))

    current_buffer = 11
    supported = false
    folding.refresh(11)
    assert.equals("0", folding.foldexpr(1))
  end)
end

T["AUI-FOLD-PRIORITY-01 prefers LSP before treesitter and indent"] = function()
  local current_buffer = 5
  local client = { supports_method = function() return true end }
  with_folding({ enabled = true, methods = { "lsp", "treesitter", "indent" } }, {
    preload = {
      ["astrocore.treesitter"] = function() error "treesitter should not run while LSP folding is available" end,
    },
    vim = {
      api = setup_api {
        nvim_get_current_buf = function() return current_buffer end,
        nvim_buf_is_valid = function() return true end,
      },
      lsp = {
        get_clients = function() return { client } end,
        foldexpr = function() return "lsp-fold" end,
      },
    },
  }, function(folding)
    folding.refresh(current_buffer)
    assert.equals("lsp-fold", folding.foldexpr(1))
  end)
end

T["AUI-FOLD-PRIORITY-02 falls back from unavailable LSP to treesitter"] = function()
  with_folding({ enabled = true, methods = { "lsp", "treesitter", "indent" } }, {
    loaded = {
      ["astrocore.treesitter"] = {
        has_parser = function(_, query) return query == "folds" end,
        is_enabled = function() return true end,
      },
    },
    vim = {
      api = setup_api {
        nvim_get_current_buf = function() return 5 end,
        nvim_buf_is_valid = function() return true end,
      },
      lsp = { get_clients = function() return {} end },
      treesitter = { foldexpr = function() return "treesitter-fold" end },
    },
  }, function(folding) assert.equals("treesitter-fold", folding.foldexpr(1)) end)
end

T["AUI-FOLD-PRIORITY-03 skips disabled treesitter and falls through to indent"] = function()
  local original_buffer = vim.api.nvim_get_current_buf()
  local buffer = vim.api.nvim_create_buf(false, true)
  local ok, result = xpcall(function()
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "  content" })
    vim.bo[buffer].shiftwidth = 2

    with_folding({ enabled = true, methods = { "treesitter", "indent" } }, {
      loaded = {
        ["astrocore.treesitter"] = {
          has_parser = function() return true end,
          is_enabled = function() return false end,
        },
      },
      vim = {
        api = setup_api(),
        treesitter = { foldexpr = function() error "disabled treesitter ran foldexpr" end },
      },
    }, function(folding) assert.equals(1, folding.foldexpr(1)) end)
  end, debug.traceback)
  vim.api.nvim_set_current_buf(original_buffer)
  vim.api.nvim_buf_delete(buffer, { force = true })
  if not ok then error(result, 0) end
end

T["AUI-FOLD-INDENT-01 handles blank lines and a zero shiftwidth with tabstop"] = function()
  local original_buffer = vim.api.nvim_get_current_buf()
  local buffer = vim.api.nvim_create_buf(false, true)
  local ok, result = xpcall(function()
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "    content", "" })
    vim.bo[buffer].shiftwidth = 0
    vim.bo[buffer].tabstop = 4

    with_folding({ enabled = true, methods = { "lsp", "treesitter", "indent" } }, {
      loaded = {
        ["astrocore.treesitter"] = {
          has_parser = function() return false end,
          is_enabled = function() return false end,
        },
      },
      vim = {
        api = setup_api(),
        lsp = { get_clients = function() return {} end },
      },
    }, function(folding)
      assert.equals(1, folding.foldexpr(1))
      assert.equals("=", folding.foldexpr(2))
    end)
  end, debug.traceback)
  vim.api.nvim_set_current_buf(original_buffer)
  vim.api.nvim_buf_delete(buffer, { force = true })
  if not ok then error(result, 0) end
end

T["AUI-FOLD-FALLBACK-01 ignores unknown methods"] = function()
  with_folding({ enabled = true, methods = { "unknown" } }, {
    vim = { api = setup_api() },
  }, function(folding) assert.equals("0", folding.foldexpr(1)) end)
end

T["AUI-FOLD-FALLBACK-02 returns no folds when disabled without checking providers"] = function()
  with_folding({ enabled = false, methods = { "lsp" } }, {
    vim = {
      api = setup_api(),
      lsp = { foldexpr = function() error "disabled folding checked the LSP provider" end },
    },
  }, function(folding) assert.equals("0", folding.foldexpr(1)) end)
end

T["AUI-FOLD-LAZY-SETUP-01 initializes folding setup on the first foldexpr call"] = function()
  local commands = {}
  with_folding({ enabled = false, methods = {} }, {
    vim = {
      api = {
        nvim_create_user_command = function(name, callback, options)
          commands[name] = { callback = callback, options = options }
        end,
        nvim_create_augroup = function() return 6 end,
        nvim_create_autocmd = function() end,
      },
    },
  }, function(folding) assert.equals("0", folding.foldexpr(1)) end)

  assert.equals("Display folding information", commands.AstroFoldInfo.options.desc)
end

T["AUI-FOLD-SETUP-01 registers the command and handles every folding event payload"] = function()
  local current_buffer = 1
  local commands = {}
  local callbacks = {}
  local clients = {}
  local client_queries = {}
  local function client(id, supported)
    return {
      id = id,
      supports_method = function(_, method, bufnr)
        assert.equals("textDocument/foldingRange", method)
        assert.is_number(bufnr)
        return supported
      end,
    }
  end

  with_folding({ enabled = true, methods = { "lsp" } }, {
    vim = {
      api = {
        nvim_create_user_command = function(name, callback, options)
          commands[name] = { callback = callback, options = options }
        end,
        nvim_create_augroup = function() return 17 end,
        nvim_create_autocmd = function(event, options)
          if type(event) == "table" then
            callbacks.BufDelete = options.callback
            callbacks.BufWipeout = options.callback
          else
            callbacks[event] = options.callback
            if event == "User" then assert.equals("AstroLspCapability", options.pattern) end
          end
        end,
        nvim_get_current_buf = function() return current_buffer end,
        nvim_buf_is_valid = function() return true end,
      },
      lsp = {
        get_clients = function(opts)
          table.insert(client_queries, opts.bufnr)
          return clients[opts.bufnr] or {}
        end,
        foldexpr = function() return "lsp-fold" end,
      },
    },
  }, function(folding)
    folding.setup()

    assert.equals("Display folding information", commands.AstroFoldInfo.options.desc)
    commands.AstroFoldInfo.callback()
    assert.is_function(callbacks.LspAttach)
    assert.is_function(callbacks.LspDetach)
    assert.is_function(callbacks.User)
    assert.is_function(callbacks.BufDelete)
    assert.is_function(callbacks.BufWipeout)

    clients[1] = { client(1, true) }
    callbacks.LspAttach { buf = 1, data = { client_id = 1 } }
    assert.equals("lsp-fold", folding.foldexpr(1))

    clients[1] = { client(2, true) }
    callbacks.LspDetach { buf = 1, data = { client_id = 1 } }
    assert.equals("lsp-fold", folding.foldexpr(1))

    clients[1] = {}
    callbacks.LspDetach { buf = 1, data = { client_id = 2 } }
    assert.equals("0", folding.foldexpr(1))

    clients[2] = { client(3, true) }
    callbacks.User { buf = 1, data = { client_id = 3, bufnr = 2 } }
    current_buffer = 2
    assert.equals("lsp-fold", folding.foldexpr(1))

    local queries_after_valid_event = #client_queries
    callbacks.User { buf = 1, data = {} }
    callbacks.User { buf = 1, data = { client_id = "3", bufnr = 2 } }
    callbacks.User { buf = 1, data = { client_id = 3, bufnr = "2" } }
    assert.equals(queries_after_valid_event, #client_queries)

    clients[3] = { client(4, true) }
    callbacks.LspAttach { buf = 3, data = { client_id = 4 } }
    current_buffer = 3
    assert.equals("lsp-fold", folding.foldexpr(1))
    callbacks.BufDelete { buf = 3 }
    assert.equals("0", folding.foldexpr(1))

    clients[4] = { client(5, true) }
    callbacks.LspAttach { buf = 4, data = { client_id = 5 } }
    current_buffer = 4
    assert.equals("lsp-fold", folding.foldexpr(1))
    callbacks.BufWipeout { buf = 4 }
    assert.equals("0", folding.foldexpr(1))
  end)
end

T["AUI-FOLD-INFO-01 reports availability, configured methods, and info severity"] = function()
  local notification
  local client = { supports_method = function() return true end }
  with_folding({ enabled = true, methods = { "unknown", "lsp" } }, {
    loaded = {
      astrocore = {
        notify = function(message, level, options)
          notification = { message = message, level = level, options = options }
        end,
      },
    },
    vim = {
      api = setup_api {
        nvim_get_current_buf = function() return 8 end,
        nvim_buf_is_valid = function() return true end,
      },
      lsp = { get_clients = function() return { client } end, foldexpr = function() return "lsp-fold" end },
    },
  }, function(folding)
    folding.refresh(8)
    folding.info(8)
  end)

  assert.equals(vim.log.levels.INFO, notification.level)
  assert.equals("AstroNvim Folding", notification.options.title)
  assert.is_true(notification.message:find("Buffer folding is %*%*Enabled%*%*", 1) ~= nil)
  assert.is_true(notification.message:find("`unknown`: %*Invalid%*", 1) ~= nil)
  assert.is_true(notification.message:find("`lsp`: Available", 1, true) ~= nil)
  assert.is_true(notification.message:find('methods = { "unknown", "lsp" }', 1, true) ~= nil)
end

return T
