## v1.2.4 (2017-07-23)
- Fix not able to align trailing comment

## v1.2.3 (2017-06-22)
- Fix config selector not matching language properly

## v1.2.2 (2017-06-14)
- Prevent aligning when no editor is passing in (#69)

## v1.2.1 (2017-05-26)
- Fix aligning same character even when scope doesn't match

## v1.2.0 (2017-05-18)
- Fix not prompting to install depended packages

## v1.1.0 (2017-05-17)
- Use cursor scope instead of root scope for matching selector

## v1.0.0 (2017-05-13)
- Bump `extend` to v3.0.1
- Update to use configSchema
- Add aligner-javascript as dependency
- Remove basic config.json

## v0.22.3 (2016-12-05)
- Fix formatter not aligning the correct character (#65)

## v0.22.2 (2016-09-25)
- Fix aligning trailing comment duplicates comments

## v0.22.1 (2016-08-03)
- Fix deprecated displayBuffer

## v0.22.0 (2016-04-29)
- Fix aligning comment only line throws TypeError
- Add punctuation as : scope

## v0.21.0 (2016-04-16)
- Add support for whitespace as separator

## v0.20.0 (2016-04-10)
- Bump minimum Atom requirement to 1.6.0
- Fully convert Aligner to JS

## v0.19.1 (2016-02-16)
- Switch back to function instead of es2015 =>

## v0.19.0 (2016-02-14)
- Add align trailing comments feature

## v0.18.1 (2016-01-31)
- Fix tab getting converted to spaces when hiding invisibles

## v0.18.0 (2016-01-29)
- Minor performance optimization
- Begin switching to ES2015 Javascript

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
