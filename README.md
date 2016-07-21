# aligner package [![Build Status](https://img.shields.io/travis/adrianlee44/atom-aligner/master.svg?style=flat-square)](https://travis-ci.org/adrianlee44/atom-aligner)

Easily align multi-line with support for different operators and custom configurations

Mac: `ctrl-cmd-/` Linux/Windows: `ctrl-alt-/`

![aligner](https://raw.github.com/adrianlee44/atom-aligner/master/demo.gif)

### Custom configuration
Package allows user to change the way characters are aligned.
- Pad either left or right of character
- If an extra whitespace should be added to the left and/or right of the character
- Aligning trailing comments when aligning characters

##### Supported Languages
- Javascript ([aligner-javascript](https://github.com/adrianlee44/atom-aligner-javascript))
- Coffeescript
- Ruby ([aligner-ruby](https://github.com/adrianlee44/atom-aligner-ruby))
- CSS & LESS ([aligner-css](https://github.com/adrianlee44/atom-aligner-css))
- SASS & SCSS ([aligner-scss](https://github.com/adrianlee44/atom-aligner-scss))
- PHP ([aligner-php](https://github.com/adrianlee44/atom-aligner-php))
- Python ([aligner-python](https://github.com/adrianlee44/atom-aligner-python))
- Stylus ([aligner-stylus](https://github.com/adrianlee44/atom-aligner-stylus))
- Lua ([aligner-lua](https://github.com/adrianlee44/atom-aligner-lua))
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
`=`: assignment
```coffeescript
foo   = "bar"
test  = "notest"
hello = "world"
```
`+=`, `-=` and other with `=`
```coffeescript
foo    = "bar"
test  += "notest"
hello -= "world"
```
`:`: Object
```coffeescript
random =
  troll: "internet"
  foo:   "bar"
  bar:   "beer"
```
`,`: Items in arrays
```coffeescript
["helloText", 123456, "world"]
["foo"      ,  32124, "bar"]
```
Comments (if `Align Comments` options on)
```javascript
var hello = 'world'; // line 1
var foo   = 'bar';   // line 2
```

## Changelog
Check [changelog](https://github.com/adrianlee44/atom-aligner/blob/master/CHANGELOG.md) for more information
