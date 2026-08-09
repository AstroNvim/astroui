# AstroUI test harness

The minimum supported Neovim version is 0.11.0. Neovim 0.12.4 stable is the exact harness baseline. Run `make test` to prepare the environment and execute all current semantic tests.

Every test target except `make test-fingerprint` first runs `make test-prepare`. The fingerprint command is intentionally independent so CI can use it as a cache key before restoring the environment. A missing `.tests/` directory is built from the fixed schema-3 dependency descriptors. The generated manifest, lockfile, copied `luassert` and `say` inventories, and `.ready` marker are validated before dependency code is loaded. A valid marked environment is reused offline without lifecycle writes.

Run `make test-update-deps` to build a fresh environment from the requested upstream refs. Run `make test-clear` to remove only this repository's canonical `.tests/` path. An unmarked, partial, unsafe, or incompatible environment fails instead of being adopted. Clear it, then prepare again. The lifecycle lock is retryable; do not remove it while another test command owns it.

The parent runner has explicit spec selection and runs offline. It prepends the local AstroUI checkout and generated dependency paths. `tests/unit_helpers.lua` restores package entries and the Vim primitives used by AstroUI, including notifications and scheduled callbacks. AstroUI does not use `vim.defer_fn`, so the harness does not replace it or fake libuv handles.

Child tests use temporary cross-platform roots with isolated XDG paths. They have bounded waits, clean up child jobs, restore parent environment values, and do not create Git fixtures because AstroUI does not consume repository state directly. The fixture init loads AstroUI from the local checkout.

Add semantic assertions for owned tables, callbacks, highlights, buffers, windows, status text, and statuscolumn behavior before considering visual coverage. No visual or golden target exists because current owned behavior is expressible semantically.
