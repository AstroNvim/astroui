.PHONY: test test-semantic test-unit test-unit-harness test-unit-helpers test-core test-folding test-lazygit test-status test-setup test-child-folding test-child-status test-ffi test-prepare test-clear test-update-deps test-fingerprint

TEST_TARGETS := test test-semantic test-unit test-unit-harness test-unit-helpers test-core test-folding test-lazygit test-status test-setup test-child-folding test-child-status test-ffi

$(TEST_TARGETS): test-prepare

test:
	@nvim -l tests/minit.lua --minitest tests/unit/*.lua tests/child/*.lua

test-semantic:
	@nvim -l tests/minit.lua --minitest tests/unit/*.lua tests/child/*.lua

test-unit:
	@nvim -l tests/minit.lua --minitest tests/unit/*.lua

test-unit-harness:
	@nvim -l tests/minit.lua --minitest tests/unit/test_environment_spec.lua

test-unit-helpers:
	@nvim -l tests/minit.lua --minitest tests/unit/helpers_spec.lua

test-core:
	@nvim -l tests/minit.lua --minitest tests/unit/core_spec.lua

test-folding:
	@nvim -l tests/minit.lua --minitest tests/unit/folding_spec.lua

test-lazygit:
	@nvim -l tests/minit.lua --minitest tests/unit/lazygit_spec.lua

test-status:
	@nvim -l tests/minit.lua --minitest \
		tests/unit/status_spec.lua \
		tests/unit/status_component_spec.lua \
		tests/unit/status_condition_spec.lua \
		tests/unit/status_config_spec.lua \
		tests/unit/status_heirline_spec.lua \
		tests/unit/status_hl_spec.lua \
		tests/unit/status_init_spec.lua \
		tests/unit/status_provider_spec.lua \
		tests/unit/status_utils_spec.lua

test-setup:
	@nvim -l tests/minit.lua --minitest tests/child/setup_spec.lua

test-child-folding:
	@nvim -l tests/minit.lua --minitest tests/child/folding_spec.lua

test-child-status:
	@nvim -l tests/minit.lua --minitest tests/child/status_spec.lua

test-ffi:
	@nvim -l tests/minit.lua --minitest tests/child/ffi_spec.lua

test-prepare:
	@nvim -l tests/bootstrap.lua

test-clear:
	@nvim -l tests/clear_test_environment.lua

test-update-deps:
	@$(MAKE) test-clear
	@$(MAKE) test-prepare

test-fingerprint:
	@nvim -l tests/print_fingerprint.lua