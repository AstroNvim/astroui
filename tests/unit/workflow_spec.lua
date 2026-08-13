local MiniTest = require "mini.test"
local config = require "config"

local T = MiniTest.new_set()

local WORKFLOW_REF = "main"

local function read_file(path)
  local file = assert(io.open(path, "rb"))
  local contents = assert(file:read "*a")
  file:close()
  return contents
end

local function as_set(values)
  local result = {}
  for _, value in ipairs(values) do
    assert.is_nil(result[value])
    result[value] = true
  end
  return result
end

local function workflow_job_names(workflow)
  local jobs = assert(workflow:match "\njobs:\n(.*)")
  local names = {}
  for name in ("\n" .. jobs):gmatch "\n  ([_%a][_%w-]*):\n" do
    table.insert(names, name)
  end
  return names
end

local function workflow_job(workflow, name)
  local start = assert(workflow:find("\n  " .. name .. ":\n", 1, true))
  local finish = workflow:find("\n  [_%a][_%w-]*:\n", start + 1)
  return workflow:sub(start, finish and finish - 1 or #workflow)
end

local function make_target_body(makefile, target)
  local start = assert(makefile:find("\n" .. target .. ":\n", 1, true))
  local body_start = start + #target + 3
  local finish = makefile:find("\n[%w-]+:\n", body_start)
  return makefile:sub(body_start, finish and finish - 1 or #makefile)
end

T["AUI-WORKFLOW-01 delegates CI to pinned thin reusable callers"] = function()
  local workflow = read_file(config.root .. "/.github/workflows/ci.yml")
  local plugin_ci = workflow_job(workflow, "CI")
  local neovim_tests = workflow_job(workflow, "Tests")
  local release = workflow_job(workflow, "Release")
  local pr_title = workflow_job(workflow, "PR")

  assert.equals("AstroUI", assert(workflow:match "name: ([^\n]+)"))
  assert.same(as_set { "CI", "Tests", "Release", "PR" }, as_set(workflow_job_names(workflow)))
  assert.is_nil(workflow:find("runs-on:", 1, true))
  assert.is_nil(workflow:find("steps:", 1, true))
  assert.is_nil(workflow:find("actions/cache", 1, true))
  assert.is_nil(workflow:find("secrets: inherit", 1, true))

  assert.is_truthy(plugin_ci:find("if: ${{ github.event_name == 'pull_request' }}", 1, true))
  assert.is_truthy(plugin_ci:find("permissions:\n      contents: read", 1, true))
  assert.is_truthy(plugin_ci:find("plugin_ci.yml@" .. WORKFLOW_REF, 1, true))
  assert.is_truthy(plugin_ci:find("is_production: false", 1, true))

  assert.is_truthy(
    neovim_tests:find(
      "if: ${{ github.event_name == 'push' || github.event_name == 'pull_request' || github.event_name == 'schedule' }}",
      1,
      true
    )
  )
  assert.is_truthy(neovim_tests:find("permissions:\n      contents: read", 1, true))
  assert.is_truthy(neovim_tests:find("neovim_testing.yml@" .. WORKFLOW_REF, 1, true))

  assert.is_truthy(release:find("if: ${{ github.event_name == 'push' }}", 1, true))
  assert.is_truthy(release:find("needs: Tests", 1, true))
  assert.is_truthy(
    release:find(
      "concurrency:\n      group: ${{ github.event.repository.name }}-release\n      cancel-in-progress: false",
      1,
      true
    )
  )
  assert.is_truthy(release:find("permissions:\n      contents: write\n      pull-requests: write", 1, true))
  assert.is_truthy(release:find("secrets:\n      RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}", 1, true))
  assert.is_truthy(release:find("plugin_ci.yml@" .. WORKFLOW_REF, 1, true))
  assert.is_truthy(release:find("is_production: true", 1, true))

  assert.is_truthy(pr_title:find("if: ${{ github.event_name == 'pull_request_target' }}", 1, true))
  assert.is_truthy(pr_title:find("permissions:\n      pull-requests: read", 1, true))
  assert.is_truthy(pr_title:find("validate_pr.yml@" .. WORKFLOW_REF, 1, true))
end

T["AUI-WORKFLOW-02 enables the Windows minimum Neovim FFI lane"] = function()
  local workflow = read_file(config.root .. "/.github/workflows/ci.yml")
  local neovim_tests = workflow_job(workflow, "Tests")

  assert.is_truthy(neovim_tests:find('minimum_neovim: "0.11.0"', 1, true))
  assert.is_truthy(neovim_tests:find('stable_neovim: "0.12.4"', 1, true))
  assert.is_truthy(neovim_tests:find('cache_rotation: "1"', 1, true))
  assert.is_truthy(neovim_tests:find("timeout_minutes: 30", 1, true))
  assert.is_truthy(neovim_tests:find("enable_windows_minimum_ffi: true", 1, true))
end

T["AUI-WORKFLOW-03 keeps the fingerprint Make target standalone"] = function()
  local makefile = read_file(config.root .. "/Makefile")
  local targets = assert(makefile:match "TEST_TARGETS := ([^\n]+)")

  assert.is_truthy(makefile:find(".PHONY:", 1, true))
  assert.is_truthy(makefile:find("test-fingerprint", 1, true))
  assert.is_nil(targets:find("test-fingerprint", 1, true))
  assert.equals("\t@nvim -l tests/print_fingerprint.lua", make_target_body(makefile, "test-fingerprint"))

  local fingerprint = vim.fn.system { "nvim", "-l", config.root .. "/tests/print_fingerprint.lua" }
  assert.equals(0, vim.v.shell_error)
  assert.equals(65, #fingerprint)
  assert.is_truthy(fingerprint:match "^[a-f0-9][a-f0-9]*\n$")
end

return T
