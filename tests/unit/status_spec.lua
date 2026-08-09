local MiniTest = require "mini.test"

local T = MiniTest.new_set()

T["AUI-HARNESS-11 resolves the status cluster with generated dependencies"] = function()
  assert.is_table(require "astroui.status")
end

return T
