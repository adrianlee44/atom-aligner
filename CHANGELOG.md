## v0.17.4 (2015-12-04)
- Clean up operator config and make sure config is cleaned up properly on deactivation

## v0.17.3 (2015-11-29)
- Change throw to console error when re-registering an aligner add-on

## v0.17.2 (2015-11-19)
- Add `separator` as acceptable scope for `:`

## v0.17.1 (2015-10-22)
- Fix not using aligner user config

## v0.17.0 (2015-09-29)
- Fix not handling activating and deactivating aligner properly
  - Switch to using Disposal for listeners and registering addons
  - Simplified provider manager

## v0.16.2 (2015-09-22)
- Fix not accounting for first line indentations

## v0.16.1 (2015-09-14)
- Fix aligner breaking when updating package

## v0.16.0 (2015-09-13)
- Add support for multiple selections alignment
  - Selection blocks will be aligned with the same offset
  - Cursors will be aligned with all adjacent lines with same indentation
- Fix aligner addon packages not working on first call
- Lines with same indentation separated by comments are now considered as the same block
- Add `enabled` option to aligner addon packages

## v0.15.0 (2015-08-11)
- Align when using selection or have multiple selections
- Fix undefined appended to comment block when `align across comment` option is on

## v0.14.0 (2015-08-08)
- Add `Align across comments` option

## v0.13.1 (2015-07-23)
- Fix tab length of 4 breaks leading whitespace
- Fix trailing tab not rendering correctly after aligning

## v0.13.0 (2015-05-12)
- Multiple cursors support

## v0.12.0 (2015-05-03)
- Removed deprecated config.
- Bumped Atom requirement to v0.195.0

## v0.11.0 (2015-04-10)
- Cleaned up add-on API

## v0.10.1 (2015-04-06)
- Fixed `,` left and right space reversed (#14)

## v0.10.0 (2015-04-02)
- Fixed indentation, invisibles and tabs bugs (#15, #17).
- Removed Ruby support from `aligner`.
- Please install `aligner-ruby`.

## v0.9.1 (2015-03-23)
- Fixed add-ons not working properly

## v0.9.0 (2015-03-22)
- Add support for aligner addons

## v0.8.1 (2015-03-22)
- Renamed to aligner

## v0.8.0 (2015-02-21)
- Added user configurations (#10)

## v0.7.0 (2015-02-09)
- Updated to Atom 1.0 API and fixed prefix

## v0.6.1 (2014-09-18)
- Fixed aligning ',' (#8, #9)

## v0.6.0 (2014-09-06)
- Updated to use latest editor API

## v0.5.2 (2014-08-18)
- Removed deprecated Atom function

## v0.5.1 (2014-08-08)
- Added support for => operator

## v0.5.0 (2014-07-09)
- Added keybinding for Linux and Windows

## v0.4.0 (2014-04-29)
- Added inline array alignment support

## v0.3.1 (2014-04-18)
- Fixed aligning ':'

## v0.3.0 (2014-04-16)
- Full rewrite to make vertical-align more robust

## v0.2.0 (2014-03-06)
- Updated README

## v0.1.0 (2014-03-06)
- Initial release
