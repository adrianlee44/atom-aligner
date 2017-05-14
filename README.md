# aligner package [![Build Status](https://img.shields.io/travis/adrianlee44/atom-aligner/master.svg?style=flat-square)](https://travis-ci.org/adrianlee44/atom-aligner)

Easily align multiple lines and blocks with support for different operators and custom configurations

Mac: `ctrl-cmd-/` Linux/Windows: `ctrl-alt-/`

![aligner](https://raw.github.com/adrianlee44/atom-aligner/master/demo.gif)

### Custom configuration
Package allows user to change the way characters are aligned.
- Pad either left or right of character
- If an extra whitespace should be added to the left and/or right of the character
- Aligning trailing comments when aligning characters

##### Supported Languages
Install add-on packages to get support for the following languages:
- Javascript ([aligner-javascript](https://github.com/adrianlee44/atom-aligner-javascript))
- Coffeescript ([aligner-coffeescript](https://github.com/adrianlee44/atom-aligner-coffeescript))
- Ruby ([aligner-ruby](https://github.com/adrianlee44/atom-aligner-ruby))
- CSS & LESS ([aligner-css](https://github.com/adrianlee44/atom-aligner-css))
- SASS & SCSS ([aligner-scss](https://github.com/adrianlee44/atom-aligner-scss))
- PHP ([aligner-php](https://github.com/adrianlee44/atom-aligner-php))
- Python ([aligner-python](https://github.com/adrianlee44/atom-aligner-python))
- Stylus ([aligner-stylus](https://github.com/adrianlee44/atom-aligner-stylus))
- Lua ([aligner-lua](https://github.com/adrianlee44/atom-aligner-lua))
- For documentation to create aligner add-ons, check this  [page](https://github.com/adrianlee44/atom-aligner/wiki/Creating-aligner-add-ons)

User can either align like this,
```javascript
let random = {
  troll: "internet",
  foo:   "bar",
  bar:   "beer"
}
```
or this,
```javascript
let random = {
  troll : "internet",
  foo   : "bar",
  bar   : "beer"
}
```
For more information, visit [wiki](https://github.com/adrianlee44/atom-aligner/wiki/User-configurations)

### Supported character/operator
For supported characters/operators, see individual add-on packages.

## Changelog
Check [changelog](https://github.com/adrianlee44/atom-aligner/blob/master/CHANGELOG.md) for more information
