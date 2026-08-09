local MiniTest = require "mini.test"
local helpers = require "unit_helpers"

local T = MiniTest.new_set()

local function with_fake_vim(fake, callback)
  local original = _G.vim
  _G.vim = fake
  local ok, result = xpcall(callback, debug.traceback)
  _G.vim = original
  if not ok then error(result, 0) end
  return result
end

local function fake_vim(fields)
  local function merge(base, overrides)
    for key, value in pairs(overrides or {}) do
      if type(value) == "table" and type(base[key]) == "table" then
        merge(base[key], value)
      else
        base[key] = value
      end
    end
    return base
  end
  local function deepcopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do
      result[key] = deepcopy(item)
    end
    return result
  end
  return merge({
    tbl_get = function(tbl, ...)
      for index = 1, select("#", ...) do
        tbl = type(tbl) == "table" and tbl[select(index, ...)] or nil
      end
      return tbl
    end,
    tbl_map = function(callback, list)
      local result = {}
      for index, value in ipairs(list) do
        result[index] = callback(value)
      end
      return result
    end,
    tbl_values = function(tbl)
      local result = {}
      for _, value in pairs(tbl) do
        table.insert(result, value)
      end
      return result
    end,
    tbl_isempty = function(tbl) return next(tbl) == nil end,
    list_extend = function(target, source)
      for _, value in ipairs(source) do
        table.insert(target, value)
      end
      return target
    end,
    tbl_keys = function(tbl)
      local result = {}
      for key in pairs(tbl) do
        table.insert(result, key)
      end
      return result
    end,
    tbl_contains = function(list, value)
      for _, item in ipairs(list) do
        if item == value then return true end
      end
      return false
    end,
    deepcopy = deepcopy,
  }, fields)
end

local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do
    result[key] = copy(item)
  end
  return result
end

local function extend_tbl(defaults, options)
  local result = copy(defaults or {})
  for key, value in pairs(options or {}) do
    if type(value) == "table" and type(result[key]) == "table" then
      result[key] = extend_tbl(result[key], value)
    else
      result[key] = copy(value)
    end
  end
  return result
end

local function provider_defaults()
  return {
    signcolumn = {},
    numbercolumn = { thousands = false, culright = true },
    foldcolumn = {},
    spell = { str = "SPELL" },
    paste = { str = "PASTE" },
    macro_recording = { prefix = "@" },
    showcmd = { minwid = 0, maxwid = 5 },
    search_count = {},
    mode_text = { pad_text = false },
    percentage = { fixed_width = true, edge_text = true },
    ruler = { pad_ruler = { line = 3, char = 2 } },
    scrollbar = { chars = { "a", "b", "c", "d" } },
    close_button = { kind = "BufferClose" },
    filetype = {},
    bufnr = { suffix = "." },
    filename = {
      fallback = "Untitled",
      fname = function(bufnr) return vim.api.nvim_buf_get_name(bufnr) end,
      modify = ":t",
    },
    file_encoding = {},
    file_format = {},
    unique_path = {
      buf_name = function(bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t") end,
      bufnr = 0,
      max_length = 16,
    },
    file_modified = { str = "MOD" },
    file_read_only = { str = "RO" },
    file_icon = {},
    git_branch = {},
    git_diff = {},
    diagnostics = {},
    lsp_progress = {},
    lsp_client_names = {
      mappings = {},
      integrations = { null_ls = true, conform = true, ["nvim-lint"] = true },
      truncate = 0.25,
    },
    virtual_env = { env_names = { "env", ".env", "venv", ".venv" }, conda = { enabled = true, ignore_base = true } },
    treesitter_status = {},
    str = { str = " " },
  }
end

local function with_provider(options, callback)
  options = options or {}
  local calls = options.calls or { stylize = {} }
  local config = {
    modes = options.modes or { n = { "NORMAL" }, i = { "INSERT" }, v = { "VISUAL" } },
    providers = vim.tbl_deep_extend("force", provider_defaults(), options.providers or {}),
  }
  local status_utils = vim.tbl_extend("force", {
    stylize = function(text, opts)
      table.insert(calls.stylize, { text = text, opts = opts })
      return text or ""
    end,
    get_signs = function() return {} end,
    icon_provider = function() return "ICON" end,
    null_ls_sources = function() return {} end,
    width = function() return 80 end,
  }, options.status_utils or {})
  local loaded = vim.tbl_extend("force", {
    astrocore = {
      extend_tbl = extend_tbl,
      is_available = function() return true end,
    },
    astroui = {
      config = { status = config },
      get_icon = function(kind) return "<" .. kind .. ">" end,
      get_spinner = function() return { "-", "+" } end,
    },
    ["astroui.status.condition"] = {
      file_modified = function() return false end,
      file_read_only = function() return false end,
      treesitter_available = function() return false end,
    },
    ["astroui.status.utils"] = status_utils,
  }, options.loaded or {})
  return helpers.with_module(
    "astroui.status.provider",
    { loaded = loaded, preload = options.preload, vim = options.vim },
    function(provider) return callback(provider, calls, config) end
  )
end

T["AUI-STATUS-PROVIDER-01 renders fill and signcolumn through the styling boundary"] = function()
  with_provider(nil, function(provider, calls)
    assert.equals("%=", provider.fill())
    assert.equals("%s", provider.signcolumn { marker = "sign" })
    assert.equals("%s", calls.stylize[1].text)
    assert.equals("sign", calls.stylize[1].opts.marker)
  end)
end

T["AUI-STATUS-PROVIDER-02 renders numbercolumn virtual lines signs disabled numbering and relative states"] = function()
  local signs, requested = {}, {}
  local state = { lnum = 12345, relnum = 0, virtnum = 1, number = true, relative = true }
  local fake = fake_vim {
    v = state,
    opt = {
      number = { get = function() return state.number end },
      relativenumber = { get = function() return state.relative end },
      signcolumn = { get = function() return "number" end },
    },
  }
  with_provider({
    status_utils = {
      get_signs = function(bufnr, row)
        table.insert(requested, { bufnr, row })
        return signs
      end,
    },
  }, function(provider)
    with_fake_vim(fake, function()
      local number = provider.numbercolumn { thousands = ",", culright = false }
      assert.equals("%=", number { bufnr = 9 })
      assert.same({ { 9, 12344 } }, requested)

      state.virtnum = 0
      signs = { { number_hl_group = "Number" } }
      assert.equals("%=%l", number { bufnr = 9 })

      signs = {}
      state.number = false
      state.relative = false
      assert.equals("%=", number { bufnr = 9 })

      state.number = true
      assert.equals("%=12,345", number { bufnr = 9 })

      state.number = false
      state.relative = true
      state.relnum = 7
      assert.equals("%=7", number { bufnr = 9 })

      state.number = true
      state.relnum = 0
      assert.equals("12,345%=", number { bufnr = 9 })
    end)
  end)
end

T["AUI-STATUS-PROVIDER-03 honors culright for the relative current line"] = function()
  local fake = fake_vim {
    v = { lnum = 42, relnum = 0, virtnum = 0 },
    opt = {
      number = { get = function() return true end },
      relativenumber = { get = function() return true end },
      signcolumn = { get = function() return "no" end },
    },
  }
  with_provider(nil, function(provider)
    with_fake_vim(fake, function() assert.equals("%=42", provider.numbercolumn { culright = true }()) end)
  end)
end

T["AUI-STATUS-PROVIDER-04 uses the native foldcolumn directive on Neovim 0.12"] = function()
  with_provider(nil, function(provider)
    with_fake_vim(
      fake_vim { fn = { has = function() return 1 end } },
      function() assert.equals("%C", provider.foldcolumn { marker = "native" }) end
    )
  end)
end

T["AUI-STATUS-PROVIDER-05 renders legacy foldcolumn empty closed open and virtual shapes with FFI"] = function()
  local foldinfo = { start = 0, level = 0, llevel = 0, lines = 0 }
  local width = 0
  local ffi_calls = {}
  local state = { lnum = 10, relnum = 0, virtnum = 0 }
  local fake = fake_vim {
    v = state,
    fn = { has = function() return 0 end },
    opt_local = { fillchars = { get = function() return { foldopen = "O", foldclose = "X", foldsep = "|" } end } },
  }
  with_provider({
    preload = {
      ["astroui.ffi"] = function()
        return {
          C = {
            find_window_by_handle = function(handle, error_type)
              table.insert(ffi_calls, { handle, error_type })
              return "window"
            end,
            compute_foldcolumn = function(window, flag)
              assert.equals("window", window)
              assert.equals(0, flag)
              return width
            end,
            fold_info = function(window, line)
              assert.equals("window", window)
              assert.equals(state.lnum, line)
              return foldinfo
            end,
          },
          new = function(type_name)
            assert.equals("Error", type_name)
            return "error"
          end,
        }
      end,
    },
  }, function(provider)
    with_fake_vim(fake, function()
      local foldcolumn = provider.foldcolumn()
      assert.equals("%*", foldcolumn())

      width = 2
      assert.equals("%#CursorLineFold#  %*", foldcolumn())

      state.relnum = 1
      foldinfo = { start = 8, level = 2, llevel = 2, lines = 1 }
      assert.equals("%#FoldColumn#|X%*", foldcolumn())

      foldinfo = { start = 10, level = 2, llevel = 0, lines = 0 }
      assert.equals("%#FoldColumn#OO%*", foldcolumn())

      state.virtnum = 1
      assert.equals("%#FoldColumn#||%*", foldcolumn())
      assert.equals(5, #ffi_calls)
    end)
  end)
end

T["AUI-STATUS-PROVIDER-06 renders tab numbers and spell paste macro showcmd state"] = function()
  local recording = "q"
  local fake = fake_vim {
    wo = { spell = true },
    o = { paste = true },
    fn = { reg_recording = function() return recording end },
  }
  with_provider(nil, function(provider)
    with_fake_vim(fake, function()
      assert.equals("%3T 3 %T", provider.tabnr() { tabnr = 3 })
      assert.equals("", provider.tabnr() {})
      assert.equals("SPELL", provider.spell()())
      assert.equals("PASTE", provider.paste()())
      assert.equals("@q", provider.macro_recording()())
      recording = ""
      assert.equals("", provider.macro_recording()())
      assert.equals("%2.7(%S%)", provider.showcmd { minwid = 2, maxwid = 7 })
    end)
  end)
end

T["AUI-STATUS-PROVIDER-07 renders search counts and suppresses failures incomplete and limits"] = function()
  local query = {}
  local result = { current = 12, total = 15, maxcount = 10, incomplete = 2 }
  local fake = fake_vim {
    fn = {
      searchcount = function(opts)
        table.insert(query, opts)
        if result == "error" then error "search unavailable" end
        return result
      end,
    },
  }
  with_provider(nil, function(provider)
    with_fake_vim(fake, function()
      assert.equals(">10/>10", provider.search_count { timeout = 30, maxcount = 10 }())
      assert.same({ timeout = 30, maxcount = 10 }, query[1])

      result = "error"
      assert.is_nil(provider.search_count { timeout = 30 }())
      result = {}
      assert.is_nil(provider.search_count { timeout = 30 }())

      result = { current = 2, total = 8, maxcount = 99, incomplete = 0 }
      assert.equals("2/8", provider.search_count()())
      assert.equals(3, #query)
    end)
  end)
end

T["AUI-STATUS-PROVIDER-08 pads mode text on each requested side"] = function()
  with_provider({ modes = { i = { "INSERT" }, c = { "COMMAND!" } } }, function(provider)
    with_fake_vim(fake_vim { fn = { mode = function() return "i" end } }, function()
      assert.equals("  INSERT", provider.mode_text { pad_text = "right" }())
      assert.equals("INSERT  ", provider.mode_text { pad_text = "left" }())
      assert.equals(" INSERT ", provider.mode_text { pad_text = "center" }())
      assert.equals("INSERT", provider.mode_text { pad_text = false }())
    end)
  end)
end

T["AUI-STATUS-PROVIDER-09 renders percentage ruler and scrollbar positions"] = function()
  local line = 1
  local fake = fake_vim {
    fn = {
      line = function(mark) return mark == "." and line or 100 end,
      virtcol = function() return 4 end,
    },
    api = {
      nvim_win_get_cursor = function() return { line, 0 } end,
      nvim_buf_line_count = function() return 100 end,
    },
  }
  with_provider(nil, function(provider)
    with_fake_vim(fake, function()
      local percentage = provider.percentage { edge_text = true, fixed_width = true }
      assert.equals("Top", percentage())
      line = 100
      assert.equals("Bot", percentage())
      line = 50
      assert.equals("%2p%%", percentage())
      assert.equals(" 50:4 ", provider.ruler { pad_ruler = { line = 3, char = 2 } }())
      assert.equals("bb", provider.scrollbar { chars = { "a", "b", "c", "d" } }())
    end)
  end)
end

T["AUI-STATUS-PROVIDER-10 renders close and file metadata with fallback and buffer forwarding"] = function()
  local bufnr = 7
  local buffer = { filetype = "lua", fenc = "utf-16", fileformat = "dos" }
  local fake = fake_vim {
    api = { nvim_get_current_buf = function() return bufnr end },
    bo = { [bufnr] = buffer, [0] = buffer },
    o = { enc = "utf-8", fileformat = "unix" },
    fn = { fnamemodify = function(path) return path:match "[^/]+$" end },
  }
  with_provider(nil, function(provider)
    with_fake_vim(fake, function()
      assert.equals("<Close>", provider.close_button { kind = "Close" })
      assert.equals("lua", provider.filetype() { bufnr = bufnr })
      assert.equals("7#", provider.bufnr { suffix = "#" }())
      assert.equals(
        "named.lua",
        provider.filename {
          fname = function(received)
            assert.equals(bufnr, received)
            return "/tmp/named.lua"
          end,
          modify = ":t",
        } { bufnr = bufnr }
      )
      assert.equals("Untitled", provider.filename { fname = function() return "" end, fallback = "Untitled" }())
      assert.equals("UTF-16", provider.file_encoding() { bufnr = bufnr })
      assert.equals("DOS", provider.file_format() { bufnr = bufnr })
      buffer.fenc = ""
      buffer.fileformat = ""
      assert.equals("UTF-8", provider.file_encoding() { bufnr = bufnr })
      assert.equals("UNIX", provider.file_format() { bufnr = bufnr })
    end)
  end)
end

T["AUI-STATUS-PROVIDER-11 derives unique POSIX and Windows paths with root distinctions and truncation"] = function()
  local names = {
    [1] = "/work/one/src/main.lua",
    [2] = "/work/two/src/main.lua",
    [3] = "C:\\work\\src\\main.lua",
    [4] = "D:\\work\\src\\main.lua",
    [5] = "/very/long/directory/main.lua",
    [6] = "/other/long/directory/main.lua",
  }
  with_provider({
    providers = {
      unique_path = {
        buf_name = function(bufnr) return names[bufnr]:match "[^/\\]+$" end,
        max_length = 0,
      },
    },
    vim = {
      t = { bufs = { 1, 2, 3, 4, 5, 6 } },
      api = { nvim_buf_get_name = function(bufnr) return names[bufnr] end },
      fn = {
        strdisplaywidth = function(text) return #text end,
        strchars = function(text) return #text end,
        strcharpart = function(text, index) return text:sub(index + 1, index + 1) end,
      },
    },
  }, function(provider)
    local path = provider.unique_path { max_length = 0 }
    assert.equals("one/src/", path { bufnr = 1 })
    assert.equals("C:/work/src/", path { bufnr = 3 })
    assert.equals("D:/work/src/", path { bufnr = 4 })

    local truncated = provider.unique_path { max_length = 8 }
    assert.equals("<Ellipsi", truncated { bufnr = 5 })
  end)
end

T["AUI-STATUS-PROVIDER-12 leaves unique paths empty without duplicate names and preserves display widths"] = function()
  local names = { [1] = "/work/a.lua", [2] = "/work/b.lua" }
  with_provider({
    providers = { unique_path = { buf_name = function(bufnr) return names[bufnr]:match "[^/]+$" end, max_length = 3 } },
    vim = {
      t = { bufs = { 1, 2 } },
      api = { nvim_buf_get_name = function(bufnr) return names[bufnr] end },
      fn = {
        strdisplaywidth = function(text) return text == "..." and 2 or #text end,
        strchars = function(text) return #text end,
        strcharpart = function(text, index) return text:sub(index + 1, index + 1) end,
      },
    },
  }, function(provider) assert.equals("", provider.unique_path { bufnr = 1, max_length = 3 }()) end)
end

T["AUI-STATUS-PROVIDER-13 renders file state icon git diff and diagnostics with forwarded buffers"] = function()
  local bufnr = 7
  local condition_buffers = {}
  local buffer = { gitsigns_head = "main", gitsigns_status_dict = { added = 3 } }
  local fake = fake_vim {
    b = { [bufnr] = buffer, [0] = buffer },
    diagnostic = {
      severity = { ERROR = 1 },
      count = function(received)
        assert.equals(bufnr, received)
        return { [1] = 4 }
      end,
    },
  }
  with_provider({
    loaded = {
      ["astroui.status.condition"] = {
        file_modified = function(self)
          table.insert(condition_buffers, self.bufnr)
          return true
        end,
        file_read_only = function() return true end,
        treesitter_available = function() return true end,
      },
    },
    status_utils = {
      icon_provider = function(received)
        assert.equals(bufnr, received)
        return "FILEICON"
      end,
    },
  }, function(provider)
    with_fake_vim(fake, function()
      assert.equals("MOD", provider.file_modified { str = "MOD" } { bufnr = bufnr })
      assert.equals("RO", provider.file_read_only { str = "RO" } { bufnr = bufnr })
      assert.same({ bufnr }, condition_buffers)
      assert.equals("FILEICON", provider.file_icon() { bufnr = bufnr })
      assert.equals("main", provider.git_branch() { bufnr = bufnr })
      assert.equals("3", provider.git_diff { type = "added" } { bufnr = bufnr })
      assert.is_nil(provider.git_diff {})
      assert.equals("4", provider.diagnostics { severity = "ERROR" } { bufnr = bufnr })
      assert.is_nil(provider.diagnostics {})
      buffer.gitsigns_status_dict = nil
      buffer.minidiff_summary = { add = 2 }
      assert.equals("2", provider.git_diff { type = "added" } { bufnr = bufnr })
      assert.equals("TS", provider.treesitter_status() { bufnr = bufnr })
    end)
  end)
end

T["AUI-STATUS-PROVIDER-14 renders LSP progress with stable spinner time and all fields"] = function()
  local hrtime = 0
  with_provider({
    loaded = { astrolsp = { lsp_progress = { [1] = { title = "Index", message = "files", percentage = 50 } } } },
  }, function(provider)
    with_fake_vim(fake_vim { uv = { hrtime = function() return hrtime end } }, function()
      local progress = provider.lsp_progress()
      assert.equals("-Index files (50%)", progress())
      hrtime = 120000000
      assert.equals("+Index files (50%)", progress())
    end)
  end)
end

T["AUI-STATUS-PROVIDER-15 joins LSP clients adapters mappings deduplication and display truncation"] = function()
  local bufnr = 7
  local null_requests = {}
  local fake = fake_vim {
    bo = { [bufnr] = { filetype = "lua" }, [0] = { filetype = "lua" } },
    lsp = {
      get_clients = function(query)
        assert.equals(bufnr, query.bufnr)
        return { { name = "lua_ls", id = 1 }, { name = "null-ls", id = 2 }, { name = "lua_ls", id = 3 } }
      end,
    },
    api = {
      nvim_buf_get_name = function(received)
        assert.equals(bufnr, received)
        return "/tmp/file.lua"
      end,
    },
    fn = {
      strdisplaywidth = function(text) return text == "…" and 1 or #text end,
      strchars = function(text) return #text end,
      strcharpart = function(text, index) return text:sub(index + 1, index + 1) end,
    },
  }
  with_provider({
    loaded = {
      conform = {
        list_formatters_to_run = function(received)
          assert.equals(bufnr, received)
          return { { name = "stylua" } }
        end,
      },
      lint = {
        _resolve_linter_by_ft = function(filetype)
          assert.equals("lua", filetype)
          return { "luacheck", "lua_ls" }
        end,
      },
    },
    status_utils = {
      null_ls_sources = function(params)
        table.insert(null_requests, vim.deepcopy(params))
        return params.method == "FORMATTING" and { "stylua", "nullfmt" } or { "nullfmt", "nulllint" }
      end,
      width = function() return 20 end,
    },
  }, function(provider)
    with_fake_vim(fake, function()
      local clients = provider.lsp_client_names {
        integrations = { null_ls = true, conform = true, ["nvim-lint"] = true },
        mappings = { lua_ls = "Lua", stylua = function() return "Style" end, ["*"] = false },
        truncate = 0.4,
      }
      assert.equals("Lua, St…", clients { bufnr = bufnr })
      assert.equals(2, #null_requests)
      assert.equals(
        "",
        provider.lsp_client_names {
          integrations = { null_ls = false, conform = false, ["nvim-lint"] = false },
          mappings = { lua_ls = "Lua" },
          truncate = 0,
        } { bufnr = bufnr }
      )
      assert.equals("FORMATTING", null_requests[1].method)
      assert.equals("DIAGNOSTICS", null_requests[2].method)
      assert.equals(2, null_requests[1].client_id)
      assert.equals(bufnr, null_requests[1].bufnr)
      assert.equals("lua", null_requests[1].ft)
    end)
  end)
end

T["AUI-STATUS-PROVIDER-16 gates unavailable LSP integrations without mutating caller options"] = function()
  local caller = { integrations = { null_ls = true, conform = true, ["nvim-lint"] = true }, truncate = false }
  with_provider({
    loaded = { astrocore = { extend_tbl = extend_tbl, is_available = function() return false end } },
  }, function(provider)
    with_fake_vim(
      fake_vim {
        lsp = { get_clients = function() return { { name = "null-ls", id = 1 } } end },
        fn = { strdisplaywidth = function(text) return #text end },
      },
      function()
        assert.equals("null-ls", provider.lsp_client_names(caller)())
        assert.is_true(caller.integrations.null_ls)
        assert.is_true(caller.integrations.conform)
        assert.is_true(caller.integrations["nvim-lint"])
      end
    )
  end)
end

T["AUI-STATUS-PROVIDER-17 resolves POSIX Windows and Conda virtual environments with formatting"] = function()
  local environment = { VIRTUAL_ENV = "/work/project/.venv/", CONDA_DEFAULT_ENV = "" }
  local fake = fake_vim {
    env = environment,
    split = function(path)
      local parts = {}
      for part in path:gmatch "[^/\\]+" do
        table.insert(parts, part)
      end
      return parts
    end,
  }
  with_provider(nil, function(provider)
    with_fake_vim(fake, function()
      local virtual_env = provider.virtual_env { format = "[%s]" }
      assert.equals("[project]", virtual_env())
      environment.VIRTUAL_ENV = "C:\\work\\app\\env\\"
      assert.equals("[app]", virtual_env())
      environment.VIRTUAL_ENV = ""
      environment.CONDA_DEFAULT_ENV = "base"
      assert.is_nil(virtual_env())
      environment.CONDA_DEFAULT_ENV = "analysis"
      assert.equals("[analysis]", virtual_env())
      assert.equals("ANALYSIS", provider.virtual_env { format = function(name) return name:upper() end }())
    end)
  end)
end

T["AUI-STATUS-PROVIDER-18 renders static strings"] = function()
  with_provider(nil, function(provider) assert.equals("constant", provider.str { str = "constant" }) end)
end

return T
