operatorConfig = require './operator-config'

###
@function
@name escapeRegExp
@description
To convert string into literal string
https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
@param {String} string String to parse
@returns {String} Updated string
###
escapeRegExp = (string = "") ->
  string.replace /([.*+?^=!:${}()|\[\]\/\\\-])/g, "\\$1"

###
@function
@name getOffsetRegex
@description
Create Regular Expression for the character
@param {String} char Align character
@returns {RegExp} RegExp with character
###
getOffsetRegex = (char) ->
  config   = operatorConfig[char]
  prefixes = "#{config.prefixes.join('')}" if config.prefixes?.length > 0
  prefixes = "[#{escapeRegExp prefixes}]?"
  regex    = "(\\s*[^#{char}\\s]+)(\\s*)(#{prefixes}#{char})(\\s*).*"
  #          indent  variable   whitespace   operator   whitespace   remaining

  return new RegExp(regex)

###
@function
@name getSameIndentationRange
@description To get the start and end line number of the same indentation
@param {Editor} editor Active editor
@param {Integer} row Row to match
@returns {Object} An object with the start and end line
###
getSameIndentationRange = (editor, row, character) ->
  start  = row - 1
  end    = row + 1
  line   = editor.lineForBufferRow row
  regex  = getOffsetRegex character
  indent = editor.indentLevelForLine line
  total  = editor.getLineCount()

  output = {start: row, end: row, offset: line.match(regex)[1].length}

  while start > -1 or end < total + 1
    if start > -1
      startLine = editor.lineForBufferRow start
      if startLine? and
          editor.indentLevelForLine(startLine) is indent and
          (match = startLine.match(regex))?

        output.offset = match[1].length if match[1].length > output.offset
        output.start  = start
        start -= 1

      else
        start = -1

    if end < total + 1
      endLine = editor.lineForBufferRow end
      if endLine? and
          editor.indentLevelForLine(endLine) is indent and
          (match = endLine.match(regex))?

        output.offset = match[1].length if match[1].length > output.offset
        output.end    = end
        end           += 1

      else
        end = total + 1

  return output

###
@function
@name getAlignCharacter
@description
Get the character to align based on text
@param {String} text Text to search
@returns {String} Alignment character
###
getAlignCharacter = (text) ->
  for character, config of operatorConfig
    regex = getOffsetRegex character
    return character if text.match(regex)

module.exports = {getOffsetRegex, getSameIndentationRange, getAlignCharacter}
