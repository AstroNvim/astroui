# Changelog

## [1.1.1](https://github.com/AstroNvim/astroui/compare/v1.1.0...v1.1.1) (2024-04-21)


### Bug Fixes

* **status:** prevent left padding from being overridden by children ([38dc557](https://github.com/AstroNvim/astroui/commit/38dc5571a081bbc525ed6bd97f513840e49a8896))

## [1.1.0](https://github.com/AstroNvim/astroui/compare/v1.0.2...v1.1.0) (2024-04-16)


### Features

* **status:** allow configuration of `separated_path` delimiter ([c58628b](https://github.com/AstroNvim/astroui/commit/c58628b9eb5bea64f0f1a2e93a98f3b18978204d))


### Bug Fixes

* **status:** split on `\` rather than `/` for windows ([9c3e37b](https://github.com/AstroNvim/astroui/commit/9c3e37b46c4c5b1dea42bc6f555dd272ca3e37cc))

## [1.0.2](https://github.com/AstroNvim/astroui/compare/v1.0.1...v1.0.2) (2024-04-05)


### Bug Fixes

* **component:** redraw statusline immediately after `gitsigns` change ([1998e64](https://github.com/AstroNvim/astroui/commit/1998e64c1fa2b89bb4cb3be44e2262016d2d0fc0))

## [1.0.1](https://github.com/AstroNvim/astroui/compare/v1.0.0...v1.0.1) (2024-04-04)


### Bug Fixes

* **status:** inconsistent padding for `file_read_only` and `file_modified` ([d2c6f24](https://github.com/AstroNvim/astroui/commit/d2c6f2423de55af30cc7ad8bc5df4b0ea04adcf4))

## 1.0.0 (2024-03-07)


### ⚠ BREAKING CHANGES

* **condition:** hard code and strongly type buffer matchers
* **component:** change defaults for `file_info` component
* **provider:** add more integrations to `lsp_client_names` provider

### Features

* add `get_hlgroup` function ([25c0cf1](https://github.com/AstroNvim/astroui/commit/25c0cf1bdb1644d9385a7ed2f27774f8d356555a))
* add auto completion with `lua_ls` ([4a6995b](https://github.com/AstroNvim/astroui/commit/4a6995bfd9e2a62ea369e46e258c4cc24ed4ac28))
* add status API ([0ec1124](https://github.com/AstroNvim/astroui/commit/0ec1124a59012bbbc7b22dd68648d92ec6d3637d))
* add utilities for configuring icons ([568a829](https://github.com/AstroNvim/astroui/commit/568a829a5cf91dc894409993d28a662a00154274))
* allow `highlights` table to have functions as well ([2eff404](https://github.com/AstroNvim/astroui/commit/2eff404ce431cf40ec6adb842ea7038e4d7a39df))
* allow function for `status.colors` table ([57f6ce3](https://github.com/AstroNvim/astroui/commit/57f6ce326984c06daace0a972ebeb5696bffdd0a))
* **condition:** add `is_file` condition ([b4d1825](https://github.com/AstroNvim/astroui/commit/b4d1825f5c0c6291ba553a87f4cb8bfef2cab460))
* **condition:** hard code and strongly type buffer matchers ([f333d52](https://github.com/AstroNvim/astroui/commit/f333d5269f6d77071e57b856c770000997efd2a8))
* **config:** improve highlight table typing ([1eb13f8](https://github.com/AstroNvim/astroui/commit/1eb13f87db5640e4cc366a2b8e7e5caef519dc38))
* **highlights:** pass `colors_name` to highlights functions ([16945ad](https://github.com/AstroNvim/astroui/commit/16945adae868a61273cd6cd2b70c9b06c853cc1f))
* **provider:** add `nvim-lint` support to `lsp_client_names` ([ec20fce](https://github.com/AstroNvim/astroui/commit/ec20fce4aed23da5a37781e8821e4e0de1b0b6c4))
* **provider:** add more integrations to `lsp_client_names` provider ([e3c98a1](https://github.com/AstroNvim/astroui/commit/e3c98a1cf8236ec012aa2b1c4946c9496d4aaf6a))
* set up colorscheme and highlight extensions ([433343a](https://github.com/AstroNvim/astroui/commit/433343a46d5e303461150e0e7637938d0e7434b5))
* **status:** add ability to freely update surrounded separators ([f63eb6d](https://github.com/AstroNvim/astroui/commit/f63eb6d4e4ce5b60fc7d2093ad3d0619cfee7e15))
* **status:** add conda support to virtual environment component ([8797cf8](https://github.com/AstroNvim/astroui/commit/8797cf8e40db4e52bedaadef78e3a09688020d61))
* **status:** add utility to refresh heirline colors ([89ee358](https://github.com/AstroNvim/astroui/commit/89ee358f48ae82d8db019289243a1941d1bbf6e4))
* **status:** add virtual environment component ([4680f7f](https://github.com/AstroNvim/astroui/commit/4680f7f0934f6638f47494a173abbdc2f8f759a5))


### Bug Fixes

* `astrocore.utils` moved to `astrocore` ([7eecd43](https://github.com/AstroNvim/astroui/commit/7eecd4391e9f3443f8ebe72b9a12b854574b9a3a))
* add missing `setup_colors` config entry ([3203015](https://github.com/AstroNvim/astroui/commit/3203015cf31866e0af3fd2d2419cf87414f4e722))
* add missing `signcolumn_enabled` condition ([504623c](https://github.com/AstroNvim/astroui/commit/504623cab47104829a3f9f3d1e942038c5cac2fd))
* **autocmds:** simiplify colorscheme setting ([738c842](https://github.com/AstroNvim/astroui/commit/738c84241445b2f9a7522d834c6a59930edbf697))
* **component:** fix `signcolumn` click handler when no sign ([a560366](https://github.com/AstroNvim/astroui/commit/a560366545a59c538c3b603bba57533d34a895b6))
* **component:** fix missing file modified element in tabline file_info ([937aaec](https://github.com/AstroNvim/astroui/commit/937aaec7a21a004f28b2229ed8c2119dcadcedc9))
* **component:** improve signcolumn handler preference when name is an empty string ([43898f1](https://github.com/AstroNvim/astroui/commit/43898f119cb145e86aa40359c4e6b7736147005b))
* **component:** update click function deferment ([27c0d50](https://github.com/AstroNvim/astroui/commit/27c0d509b11e810f29d46d4d349f3b1f157063b4))
* **component:** update LSP provider on resize for truncation ([edda875](https://github.com/AstroNvim/astroui/commit/edda875a0ad25a2b00e516884966e834a2711f0f))
* **condition:** check if `nvim-lint` has clients attached ([d466f21](https://github.com/AstroNvim/astroui/commit/d466f2132f723c5bc88887d5be3bad948cb50f9f))
* **condition:** diagnostics configuration moved to AstroCore ([cb7fb48](https://github.com/AstroNvim/astroui/commit/cb7fb4877d778a90be2a7fe2bee9f114f21d00a2))
* **condition:** loosen validity check in `buffer_matches` ([d4fb5c2](https://github.com/AstroNvim/astroui/commit/d4fb5c2a61d649aac04b24ab23eeb82915863597))
* **config:** fix typo ([ff365ce](https://github.com/AstroNvim/astroui/commit/ff365ce10537cfd97c5253dd5538e96b3a62e3ef))
* move `icons_enabled` back to global variable ([df753ac](https://github.com/AstroNvim/astroui/commit/df753ac660fb0ac3dee5a8a020e371ac7719d940))
* **provider:** fix `statuscolumn=number` in neovim 0.10 ([1f08c9f](https://github.com/AstroNvim/astroui/commit/1f08c9f0b3875a33a08727c0725670800dc61892))
* **status:** always clear cache when running update callback ([ab8ce32](https://github.com/AstroNvim/astroui/commit/ab8ce327064f383cecc1ea5cc5de576a91a93c34))
* **status:** always show fallback for files without a name ([d5d5291](https://github.com/AstroNvim/astroui/commit/d5d5291c9872dcf9b218d18c9e789de9ba35457a))
* **status:** clean up `bufnr` throughout `condition` and `provider` ([87716d0](https://github.com/AstroNvim/astroui/commit/87716d0090bcff82c2f6713f7fae4375d7472dbd))
* **status:** fix `file_icon` provider to fallback to filetype ([6d929e7](https://github.com/AstroNvim/astroui/commit/6d929e7c4ca046d13055e19675f7a3ca36213f7e))
* **status:** fix conform integration with clients ([695da66](https://github.com/AstroNvim/astroui/commit/695da660570ff9f93b8f5c84f417ebeb82e81f58))
* **status:** fix number column when `signcolumn=number` ([36db241](https://github.com/AstroNvim/astroui/commit/36db241b65fb57f6270ba1ce9f20f4b75cb02e9d))
* **status:** fix typo in `foldcolumn` component ([04e2bc5](https://github.com/AstroNvim/astroui/commit/04e2bc5dfe08ef786958065412a688fccea03770))
* **status:** incorrect return def in buffer_matches ([ab11856](https://github.com/AstroNvim/astroui/commit/ab1185696f353b1f0ef30af1a5b8a0b822cd144e))
* **status:** make sure only valid buffers are passed to heirline tabline ([be85280](https://github.com/AstroNvim/astroui/commit/be85280c069b9fb3842a7320f035a6d132d2e686))
* **status:** move click handlers to use extmarks instead of legacy signs ([a310ab1](https://github.com/AstroNvim/astroui/commit/a310ab117610c09da2fa3a21433a4ea5d026c448))
* **status:** typo causing CI Spell Check fail ([c14fc11](https://github.com/AstroNvim/astroui/commit/c14fc1134228bf1d6968d385240d9c5600c08825))
* **status:** use `vim.tbl_islist` to resolve 0.9 compatibility ([f3af022](https://github.com/AstroNvim/astroui/commit/f3af0226a21da364ef948991fdbdadbf824fad3a))
* **status:** use buffer git root with Telescope ([76edc8e](https://github.com/AstroNvim/astroui/commit/76edc8e2a9f8e1bf3203e59c6836421d9096bbd9))


### Performance Improvements

* **provider:** disable integrations that are unavailable ([7f3e0a5](https://github.com/AstroNvim/astroui/commit/7f3e0a50e99dc1b49d6da1147a14db2fbaa871ae))
* **status:** further improve performance of `file_icon` provider ([a2ca828](https://github.com/AstroNvim/astroui/commit/a2ca8289202829f8f986d1318c90d9508649f383))
* **status:** optimize updating of surrounded components ([af8b51e](https://github.com/AstroNvim/astroui/commit/af8b51e221b5947933030045edb4eb14e4f954c1))
* **status:** use `vim.diagnostic.count` if available ([694e0a7](https://github.com/AstroNvim/astroui/commit/694e0a7e7cf74ff7db73ea97458533879db50646))


### Code Refactoring

* **component:** change defaults for `file_info` component ([b7a04fb](https://github.com/AstroNvim/astroui/commit/b7a04fb2eb4879cc97cd6e9f04ebc9085240c16c))
