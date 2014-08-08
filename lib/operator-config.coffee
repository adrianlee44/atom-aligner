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
    scope:      "operator|assignment"
  }
  ",": {
    leftSpace:  true
    rightSpace: false
    prefixes:   []
    scope:      "delimiter"
    multiple:   {
      "number":
        alignment: "left"
      "string":
        alignment: "right"
    }
  }
  "=>": {
    alignment:  "left"
    leftSpace:  true
    rightSpace: true
    scope:      "key-value"
  }
}
