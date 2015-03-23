operatorConfig = require './operator-config'

###
@function
@name parseTokenizedLine
@description
Parsing line with operator
@param {Object} tokenizedLine Tokenized line object from editor display buffer
@param {String} character Character to align
@param {Object} config Character config
@returns {Object} Information about the tokenized line including text before character,
                  text after character, character prefix, offset and if the line is
                  valid
###
parseTokenizedLine = (tokenizedLine, character, config) ->
  afterCharacter = false
  parsed         = []
  parsed.prefix  = null
  section        =
    before: ""
    after:  ""

  addToParsed = ->
    section.before = section.before.trimRight()
    section.after  = section.after.trimLeft()
    section.offset = section.before.length

    parsed.push section

    # clear the original section
    section =
      before: ""
      after:  ""

  for token in tokenizedLine.tokens
    tokenValue = token.value.trim()
    if operatorConfig.canAlignWith(character, tokenValue, config) and (not afterCharacter or config.multiple)
      parsed.prefix = operatorConfig.isPrefixed tokenValue, config

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

  tokenized = getTokenizedLineForBufferRow editor, row
  scope     = editor.getRootScopeDescriptor().getScopeChain()
  config    = operatorConfig.getConfig character, scope

  parsed    = parseTokenizedLine tokenized, character, config
  indent    = editor.indentationForBufferRow row
  total     = editor.getLineCount()
  hasPrefix = parsed.prefix

  output = {start: row, end: row, offset: []}

  checkOffset = (parsedObjects) ->
    for parsedObject, i in parsedObjects
      output.offset[i] ?= parsedObject.offset

      if parsedObject.offset > output.offset[i]
        output.offset[i] = parsedObject.offset

  checkOffset parsed

  while start > -1 or end < total
    if start > -1
      startLine = getTokenizedLineForBufferRow editor, start

      if startLine? and editor.indentationForBufferRow(start) is indent and
          (parsed = parseTokenizedLine startLine, character, config) and parsed.valid

        checkOffset parsed
        output.start  = start
        hasPrefix     = true if not hasPrefix and parsed.prefix
        start        -= 1

      else
        start = -1

    if end < total + 1
      endLine = getTokenizedLineForBufferRow editor, end

      if endLine? and editor.indentationForBufferRow(end) is indent and
          (parsed = parseTokenizedLine endLine, character, config) and parsed.valid

        checkOffset parsed
        output.end  = end
        hasPrefix   = true if not hasPrefix and parsed.prefix
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
@param {String} scope
@returns {String} Alignment character
###
getTokenizedAlignCharacter = (tokens, scope = 'base') ->
  for token, i in tokens
    tokenValue = token.value.trim()

    config = operatorConfig.getConfig tokenValue, scope
    continue unless config

    for scope in token.scopes when scope.match(config.scope)?
      return tokenValue

getTokenizedLineForBufferRow = (editor, row) ->
  editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(row)

module.exports = {
  getSameIndentationRange
  parseTokenizedLine
  getTokenizedAlignCharacter
  getTokenizedLineForBufferRow
}
