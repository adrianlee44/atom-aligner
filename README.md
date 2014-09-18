# vertical-align package [![Build Status](https://travis-ci.org/adrianlee44/atom-vertical-align.svg?branch=master)](https://travis-ci.org/adrianlee44/atom-vertical-align)

Align elements and operators in Atom

- Mac: `ctrl-cmd-/`
- Linux/Windows: `ctrl-alt-/`

![vertical-align](https://raw.github.com/adrianlee44/atom-vertical-align/master/demo.gif)

##### Tested Supported Languages
- Javascript
- Coffeescript
- Ruby

## Examples
### Assignment
From:
```coffeescript
foo = "bar"
test = "notest"
hello = "world"
```

To:
```coffeescript
foo   = "bar"
test  = "notest"
hello = "world"
```

### Assignment Operator
From:
```coffeescript
foo = "bar"
test += "notest"
hello -= "world"
```

To:
```coffeescript
foo    = "bar"
test  += "notest"
hello -= "world"
```

### Object
From:
```coffeescript
random =
  troll: "internet"
  foo: "bar"
  bar: "beer"
```

To:
```coffeescript
random =
  troll: "internet"
  foo:   "bar"
  bar:   "beer"
```

### Items in arrays
From:
```coffeescript
["helloText", 123456, "world"]
["foo", 32124, "bar"]
```

To:
```coffeescript
["helloText", 123456, "world"]
["foo"      ,  32124, "bar"]
```

## Changelog
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
- Allow custom configurations
- Add multi-cursors support
