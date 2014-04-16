# vertical-align package

`ctrl-cmd-/` to align operators.

![vertical-align](https://raw.github.com/adrianlee44/atom-vertical-align/master/demo.gif)

## Examples
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

## Changelog
- 2014-04-16   v0.3.0   Full rewrite to make vertical-align more robust
- 2014-03-06   v0.2.0   Updated README
- 2014-03-06   v0.1.0   Initial release

## TODO:
- Allow custom configurations
- Better prefix support
