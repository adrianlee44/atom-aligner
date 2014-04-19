module.exports = {
  "=": {
    alignment:  "left"
    leftSpace:  true
    rightSpace: true
    prefixes:   ["+", "-", "&", "|", "<", ">", "!", "~", "%", "/", "*", "."]
    scope:      "operator|assignment"
  }
  ":": {
    alignment:  "right"
    leftSpace:  false
    rightSpace: true
    prefixes:   []
    scope:      "operator|assignment|source"
  }
}
