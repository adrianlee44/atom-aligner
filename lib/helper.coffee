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
  before         = ""
  after          = ""
  prefix         = null
  afterCharacter = false
  config         = operatorConfig[character]

  for token in tokenizedLine.tokens
    # When operators aren't tokenized correctly
    tokenValue = token.value.trim()

    if tokenValue is character and not afterCharacter
      afterCharacter = true
      continue

    if afterCharacter
      after += token.value
    else
      before += token.value

  # When not whitespace, check prefix
  if (lastChar = before.substr(-1)) isnt " " and lastChar in config.prefixes
    prefix = lastChar
    before = before.slice(0, -1)

  offset = before.trimRight().length

  return {
    before: before.trimRight()
    after:  after.trimLeft()
    prefix: prefix
    offset: offset
    valid:  afterCharacter
  }

###
@function
@name getSameIndentationRange
@description To get the start and end line number of the same indentation
@param {Editor} editor Active editor
@param {Integer} row Row to match
@returns {Object} An object with the start and end line
###
getSameIndentationRange = (editor, row, character) ->
  start     = row - 1
  end       = row + 1
  tokenized = editor.displayBuffer.lineForRow row
  parsed    = parseTokenizedLine tokenized, character
  indent    = editor.indentLevelForLine tokenized.text
  total     = editor.getLineCount()
  hasPrefix = parsed.prefix?

  output = {start: row, end: row, offset: parsed.offset}

  while start > -1 or end < total + 1
    if start > -1
      startLine = editor.displayBuffer.lineForRow start

      if startLine? and editor.indentLevelForLine(startLine.text) is indent and
          (parsed = parseTokenizedLine startLine, character) and parsed.valid

        output.offset  = parsed.offset if parsed.offset > output.offset
        output.start   = start
        hasPrefix      = true if not hasPrefix and parsed.prefix?
        start         -= 1

      else
        start = -1

    if end < total + 1
      endLine = editor.displayBuffer.lineForRow end

      if endLine? and editor.indentLevelForLine(endLine.text) is indent and
          (parsed = parseTokenizedLine endLine, character) and parsed.valid

        output.offset  = parsed.offset if parsed.offset > output.offset
        output.end     = end
        hasPrefix      = true if not hasPrefix and parsed.prefix?
        end           += 1

      else
        end = total + 1

  output.offset += 1 if hasPrefix

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
