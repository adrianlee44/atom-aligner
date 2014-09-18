operatorConfig = require './operator-config'

###
@function
@name parseTokenizedLine
@description
Parsing line with operator
@param {Object} tokenizedLine Tokenized line object from editor display buffer
@param {String} character Character to align
@returns {Object} Information about the tokenized line including text before character,
                  text after character, character prefix, offset and if the line is
                  valid
###
parseTokenizedLine = (tokenizedLine, character) ->
  afterCharacter = false
  config         = operatorConfig[character]
  parsed         = []
  parsed.prefix  = null
  section        =
    before: ""
    after:  ""

  addToParsed = ->
    # When not whitespace, check prefix
    if (lastChar = section.before.substr(-1)) isnt " " and lastChar in config.prefixes
      parsed.prefix  = lastChar
      section.before = section.before.slice(0, -1)

    section.before = section.before.trimRight()
    section.after  = section.after.trimLeft()
    section.offset = section.before.length

    parsed.push section

    # clear the original section
    section =
      before: ""
      after:  ""

  for token in tokenizedLine.tokens
    # When operators aren't tokenized correctly
    tokenValue = token.value.trim()

    if tokenValue is character and (not afterCharacter or config.multiple)
      if config.multiple
        addToParsed()

      afterCharacter = true
      continue

    variable           = if afterCharacter and not config.multiple then "after" else "before"
    section[variable] += token.value

  # Add the last section to pared
  addToParsed()
  parsed.valid = afterCharacter

  return parsed

###
@function
@name getSameIndentationRange
@description To get the start and end line number of the same indentation
@param {Editor} editor Active editor
@param {Integer} row Row to match
@returns {Object} An object with the start and end line
###
getSameIndentationRange = (editor, row, character) ->
  start = row - 1
  end   = row + 1

  grammar   = editor.getGrammar()
  tokenized = grammar.tokenizeLine editor.lineTextForBufferRow row

  parsed    = parseTokenizedLine tokenized, character
  indent    = editor.indentationForBufferRow row
  total     = editor.getLineCount()
  hasPrefix = parsed.prefix?

  output = {start: row, end: row, offset: []}

  checkOffset = (parsedObjs) ->
    for parsedItem, i in parsedObjs
      output.offset[i] ?= parsedItem.offset

      if parsedItem.offset > output.offset[i]
        output.offset[i] = parsedItem.offset

  checkOffset parsed

  while start > -1 or end < total
    if start > -1
      startLine = grammar.tokenizeLine editor.lineTextForBufferRow start

      if startLine? and editor.indentationForBufferRow(start) is indent and
          (parsed = parseTokenizedLine startLine, character) and parsed.valid

        checkOffset parsed
        output.start  = start
        hasPrefix     = true if not hasPrefix and parsed.prefix?
        start        -= 1

      else
        start = -1

    if end < total + 1
      endLine = grammar.tokenizeLine editor.lineTextForBufferRow end

      if endLine? and editor.indentationForBufferRow(end) is indent and
          (parsed = parseTokenizedLine endLine, character) and parsed.valid

        checkOffset parsed
        output.end  = end
        hasPrefix   = true if not hasPrefix and parsed.prefix?
        end        += 1

      else
        end = total + 1

  if hasPrefix
    output.offset = output.offset.map (item) -> item + 1

  return output

###
@function
@name getTokenizedAlignCharacter
@description
Get the character to align based on text
@param {Array} tokens Line tokens
@returns {String} Alignment character
###
getTokenizedAlignCharacter = (tokens) ->
  for token, i in tokens
    tokenValue = token.value.trim()
    config     = operatorConfig[tokenValue]
    continue unless config

    for scope in token.scopes when scope.match(config.scope)?
      return tokenValue

module.exports = {
  getSameIndentationRange
  parseTokenizedLine
  getTokenizedAlignCharacter
}
