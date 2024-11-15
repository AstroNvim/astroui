# Changelog

## [2.5.1](https://github.com/AstroNvim/astroui/compare/v2.5.0...v2.5.1) (2024-11-15)


### Bug Fixes

* **config:** fix type annotation for `lazygit` disabling ([0893053](https://github.com/AstroNvim/astroui/commit/08930530985ba38c4586d072b07d2181f227571c))

## [2.5.0](https://github.com/AstroNvim/astroui/compare/v2.4.5...v2.5.0) (2024-11-14)


### Features

* add Lazygit theming integration ([8e31ccd](https://github.com/AstroNvim/astroui/commit/8e31ccdfeb88d42e4bb7101b2f43cb620284146b))

## [2.4.5](https://github.com/AstroNvim/astroui/compare/v2.4.4...v2.4.5) (2024-09-03)


### Bug Fixes

* return fully cleared highlight groups ([9bd674c](https://github.com/AstroNvim/astroui/commit/9bd674c2f100433d2fa19952aa2a719bca464b71))

## [2.4.4](https://github.com/AstroNvim/astroui/compare/v2.4.3...v2.4.4) (2024-08-05)


### Performance Improvements

* **condition:** optimize checking of active treesitter ([79e10b1](https://github.com/AstroNvim/astroui/commit/79e10b1133d400f978d745766432805ad2fd2683))

## [2.4.3](https://github.com/AstroNvim/astroui/compare/v2.4.2...v2.4.3) (2024-07-19)


### Bug Fixes

* **status:** update `conform` integration to use non-deprecated functions ([dc224f1](https://github.com/AstroNvim/astroui/commit/dc224f1b2596ba5e1888cb87b2870a6cbbba2ab5))

## [2.4.2](https://github.com/AstroNvim/astroui/compare/v2.4.1...v2.4.2) (2024-07-17)


### Bug Fixes

* fix backwards compatibility with neovim v0.9+ ([1e46a32](https://github.com/AstroNvim/astroui/commit/1e46a3294fb1f539976c5e4ef39df1a343239177))

## [2.4.1](https://github.com/AstroNvim/astroui/compare/v2.4.0...v2.4.1) (2024-07-17)


### Bug Fixes

* only return highlights that do highlighting ([ce53a09](https://github.com/AstroNvim/astroui/commit/ce53a09bf2b1e71e38269faf77ba34c1de3e06b4))
* **status:** protect table indexing ([37ad2a4](https://github.com/AstroNvim/astroui/commit/37ad2a4693315a9078ddb43fc384cd13c3542c73))

## [2.4.0](https://github.com/AstroNvim/astroui/compare/v2.3.4...v2.4.0) (2024-07-08)


### Features

* **utils:** move icon provider to a utility function with caching ([c2cd437](https://github.com/AstroNvim/astroui/commit/c2cd437b208ef0f9e8a037a2c81003519a68ced6))

## [2.3.4](https://github.com/AstroNvim/astroui/compare/v2.3.3...v2.3.4) (2024-07-08)


### Bug Fixes

* **status:** correctly resolve filetype icon with `nvim-web-devicons` ([96b64a4](https://github.com/AstroNvim/astroui/commit/96b64a455c5f902e0a6363592ad606e70f8a6f0d))

## [2.3.3](https://github.com/AstroNvim/astroui/compare/v2.3.2...v2.3.3) (2024-07-07)


### Bug Fixes

* **provider:** implement proper fallback with `mini.icons` ([0481bd9](https://github.com/AstroNvim/astroui/commit/0481bd98d849bcfd0e39ed94eb2b7d5550a74ab4))

## [2.3.2](https://github.com/AstroNvim/astroui/compare/v2.3.1...v2.3.2) (2024-07-06)


### Bug Fixes

* **status:** fix `mini.icons` detection in `hl` module as well ([41c7214](https://github.com/AstroNvim/astroui/commit/41c72141fe673476f1afc4cb63be954b91b277d9))

## [2.3.1](https://github.com/AstroNvim/astroui/compare/v2.3.0...v2.3.1) (2024-07-06)


### Bug Fixes

* **status:** correctly check if `mini.icons` is loaded ([5a34ed8](https://github.com/AstroNvim/astroui/commit/5a34ed8ccb9b61d3a4241bddfe3d2111586e8186))

## [2.3.0](https://github.com/AstroNvim/astroui/compare/v2.2.1...v2.3.0) (2024-07-05)


### Features

* **status:** add support for `mini.icons` ([0e3e040](https://github.com/AstroNvim/astroui/commit/0e3e040cfd5ec297af91eb088b31ab78d611a22b))


### Bug Fixes

* **status:** correctly display icons for non-file buffers ([d3c79f1](https://github.com/AstroNvim/astroui/commit/d3c79f10ee415c7a149d253864749ade4b58bfcc))

## [2.2.1](https://github.com/AstroNvim/astroui/compare/v2.2.0...v2.2.1) (2024-07-01)


### Bug Fixes

* **provider:** filetypes are case sensitive so don't make lowercase ([c37f726](https://github.com/AstroNvim/astroui/commit/c37f726d64e9a1864fec97f2e1ca162c12846b64))

## [2.2.0](https://github.com/AstroNvim/astroui/compare/v2.1.4...v2.2.0) (2024-06-20)


### Features

* **config:** add table for configuring winbar whitelist/blacklist ([abf4ac4](https://github.com/AstroNvim/astroui/commit/abf4ac4026e22bdc24b69e638983e8bf4b33d672))


### Bug Fixes

* **status:** filter duplicate client names ([1b4cd27](https://github.com/AstroNvim/astroui/commit/1b4cd277245aa1f4ee52d01d8b781b752bf62926))

## [2.1.4](https://github.com/AstroNvim/astroui/compare/v2.1.3...v2.1.4) (2024-05-27)


### Bug Fixes

* **provider:** use `list_formatters` instead of `list_formatters_for_buffer` ([41bbc1c](https://github.com/AstroNvim/astroui/commit/41bbc1ca47d5fe2737cd296799e636a5e4124601))

## [2.1.3](https://github.com/AstroNvim/astroui/compare/v2.1.2...v2.1.3) (2024-05-23)


### Bug Fixes

* **provider:** only show `conform` clients if not fallingback to the LSP ([1ce41ee](https://github.com/AstroNvim/astroui/commit/1ce41eec52ecc672082edfea85d61af782badd3a))

## [2.1.2](https://github.com/AstroNvim/astroui/compare/v2.1.1...v2.1.2) (2024-05-21)


### Bug Fixes

* **config:** allow `colors` function to return nothing if it performs in place modifications ([48b3d36](https://github.com/AstroNvim/astroui/commit/48b3d368755f1a2775c859b0081123a11a6a13eb))

## [2.1.1](https://github.com/AstroNvim/astroui/compare/v2.1.0...v2.1.1) (2024-05-21)


### Bug Fixes

* resolve reversed highlight groups upon resolution ([c142447](https://github.com/AstroNvim/astroui/commit/c1424472b50921c196885a9308642a5cfd0cd256))

## [2.1.0](https://github.com/AstroNvim/astroui/compare/v2.0.1...v2.1.0) (2024-05-16)


### Features

* **component:** add click support for `venv-selector.nvim` if available ([9fd2345](https://github.com/AstroNvim/astroui/commit/9fd23451c916a6dc7863660d7a89dbbb204d78b5))

## [2.0.1](https://github.com/AstroNvim/astroui/compare/v2.0.0...v2.0.1) (2024-05-14)


### Bug Fixes

* **utils:** fix `runtime_condition` check ([f078ce8](https://github.com/AstroNvim/astroui/commit/f078ce849d705cdb99c241498264eaf3a337c51c))

## [2.0.0](https://github.com/AstroNvim/astroui/compare/v1.1.2...v2.0.0) (2024-05-14)


### ⚠ BREAKING CHANGES

* **utils:** streamline parameters for `null-ls` helper functions

### Features

* **provider:** add basic `runtime_condition` checking support to `null-ls` provider ([a9e5ccb](https://github.com/AstroNvim/astroui/commit/a9e5ccb293697f6dc415f854e125c6d76a89c413))


### Code Refactoring

* **utils:** streamline parameters for `null-ls` helper functions ([4e81c0a](https://github.com/AstroNvim/astroui/commit/4e81c0a2744fcad76687f9a3b13f6baefa08ad63))

## [1.1.2](https://github.com/AstroNvim/astroui/compare/v1.1.1...v1.1.2) (2024-04-22)


### Bug Fixes

* **status:** add check for new `islist` function ([924a416](https://github.com/AstroNvim/astroui/commit/924a4160b4ef2575609309cfe7645d038c8a0a5e))


### Performance Improvements

* **component:** optimize left padding in component builder ([9e7b8a3](https://github.com/AstroNvim/astroui/commit/9e7b8a3d41d8bb5f5abe43c5fcc9e0cad3b2c858))

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
