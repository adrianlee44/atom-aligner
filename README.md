# aligner package [![Build Status](https://img.shields.io/travis/adrianlee44/atom-aligner/master.svg?style=flat-square)](https://travis-ci.org/adrianlee44/atom-aligner)

Easily align multi-line with support for different operators and custom configurations

Mac: `ctrl-cmd-/` Linux/Windows: `ctrl-alt-/`

### Update
This package has recently been renamed from `vertical-align` to `aligner` and might be causing some update problems. Please uninstall `vertical-align` and install `aligner` to fix the problem.

![aligner](https://raw.github.com/adrianlee44/atom-aligner/master/demo.gif)

### Custom configuration
Package allows user to change the way characters are aligned.
- Pad either left or right of character
- If an extra whitespace should be added to the left and/or right of the character

##### Supported Languages
- Javascript
- Coffeescript
- Ruby ([aligner-ruby](https://github.com/adrianlee44/atom-aligner-ruby))
- CSS & LESS ([aligner-css](https://github.com/adrianlee44/atom-aligner-css))
- SASS & SCSS ([aligner-scss](https://github.com/adrianlee44/atom-aligner-scss))
- For documentation to create aligner add-ons, check this  [page](https://github.com/adrianlee44/atom-aligner/wiki/Creating-aligner-add-ons)

User can either align like this,
```coffeescript
random =
  troll: "internet"
  foo:   "bar"
  bar:   "beer"
```
or this,
```coffeescript
random =
  troll : "internet"
  foo   : "bar"
  bar   : "beer"
```
For more information, visit [wiki](https://github.com/adrianlee44/atom-aligner/wiki/User-configurations)

### Supported character/operator
- `=`: assignment
```coffeescript
foo   = "bar"
test  = "notest"
hello = "world"
```
- `+=`, `-=` and other with `=`
```coffeescript
foo    = "bar"
test  += "notest"
hello -= "world"
```
- `:`: Object
```coffeescript
random =
  troll: "internet"
  foo:   "bar"
  bar:   "beer"
```
- `,`: Items in arrays
```coffeescript
["helloText", 123456, "world"]
["foo"      ,  32124, "bar"]
```

## Changelog
- 2015-04-10   v0.11.0   Cleaned up add-on API
- 2015-04-06   v0.10.1   Fixed `,` left and right space reversed (#14)
- 2015-04-02   v0.10.0   Fixed indentation, invisibles and tabs bugs (#15, #17). Removed Ruby support from `aligner`. Please install `aligner-ruby`.
- 2015-03-23   v0.9.1   Fixed add-ons not working properly
- 2015-03-22   v0.9.0   Add support for aligner addons
- 2015-03-22   v0.8.1   Renamed to aligner
- 2015-02-21   v0.8.0   Added user configurations (#10)
- 2015-02-09   v0.7.0   Updated to Atom 1.0 API and fixed prefix
- 2014-09-18   v0.6.1   Fixed aligning ',' (#8, #9)
- 2014-09-06   v0.6.0   Updated to use latest editor API
- 2014-08-18   v0.5.2   Removed deprecated Atom function
- 2014-08-08   v0.5.1   Added support for => operator
- 2014-07-09   v0.5.0   Added keybinding for Linux and Windows
- 2014-04-29   v0.4.0   Added inline array alignment support
- 2014-04-18   v0.3.1   Fixed aligning ':'
- 2014-04-16   v0.3.0   Full rewrite to make vertical-align more robust
- 2014-03-06   v0.2.0   Updated README
- 2014-03-06   v0.1.0   Initial release

## TODO:
- Add multi-cursors support
