operatorConfig = require './operator-config'
{Point, Range} = require 'atom'
SectionizedLine = require './sectionized-line'

_traverseRanges = (ranges, callback, context = this) ->
  for range, rangeIndex in ranges
    for line in range.getRows()
      return output if (output = callback.call(context, line, rangeIndex))

module.exports =
###
@name getAlignCharacter
@description
Get the character to align based on text
@param {Editor} editor
@param {number} row
@returns {String} Alignment character
###
getAlignCharacter: (editor, row) ->
  tokenized     = @getTokenizedLineForBufferRow(editor, row)
  languageScope = editor.getRootScopeDescriptor().getScopeChain() or 'base'

  return null unless tokenized

  for token in tokenized.tokens
    tokenValue = token.value.trim()

    config = operatorConfig.getConfig tokenValue, languageScope
    continue unless config

    for tokenScope in token.scopes when tokenScope.match(config.scope)?
      return tokenValue

###
@name getAlignCharacterInRanges
@description
Get the character to align within certain ranges
@param {Editor} editor
@param {Array.<Range>} ranges
@returns {String} Alignment character
###
getAlignCharacterInRanges: (editor, ranges) ->
  _traverseRanges ranges, (line) ->
    character = @getAlignCharacter editor, line
    return character if character
  , this

###
@name getOffsetsAndSectionizedLines
@description
Get alignment offset and sectionizedLines based on character and selections
@param {Editor} editor
@param {String} character
@param {Array.<Range>} ranges
@returns {{offsets:<Array>, sectionizedLines:<Array>}}
###
getOffsetsAndSectionizedLines: (editor, character, ranges) ->
  scope            = editor.getRootScopeDescriptor().getScopeChain()
  offsets          = []
  sectionizedLines = []

  _traverseRanges ranges, (line, rangeIndex) ->
    tokenized       = @getTokenizedLineForBufferRow editor, line
    config          = operatorConfig.getConfig character, scope
    sectionizedLine = @parseTokenizedLine tokenized, character, config

    sectionizedLines[rangeIndex]       ?= {}
    sectionizedLines[rangeIndex][line]  = sectionizedLine

    @setOffsets(offsets, sectionizedLine) if sectionizedLine.isValid()
    return
  , this

  return {
    offsets:          offsets,
    sectionizedLines: sectionizedLines
  }

###
@name parseTokenizedLine
@description
Parsing line with operator
@param {Object} tokenizedLine Tokenized line object from editor display buffer
@param {String} character Character to align
@param {Object} config Character config
@returns {SectionizedLine} Information about the tokenized line including text before character,
                  text after character, character prefix, offset and if the line is
                  valid
###
parseTokenizedLine: (tokenizedLine, character, config) ->
  afterCharacter       = false
  sectionizedLine      = new SectionizedLine()
  trailingCommentIndex = -1

  if atom.config.get('aligner.alignComments')
    # traverse backward for trailing comments
    for token, index in tokenizedLine.tokens by -1
      if token.matchesScopeSelector('comment')
        sectionizedLine.trailingComment = @_formatTokenValue(token, tokenizedLine.invisibles) + sectionizedLine.trailingComment
      else
        trailingCommentIndex = index + 1
        break

  for token, index in tokenizedLine.tokens
    # exit out of the loop when processing trailing comments
    break if index is trailingCommentIndex

    tokenValue = @_formatTokenValue token, tokenizedLine.invisibles

    if operatorConfig.canAlignWith(character, tokenValue.trim(), config) and (not afterCharacter or config.multiple)
      sectionizedLine.prefix = operatorConfig.isPrefixed tokenValue.trim(), config

      if config.multiple
        sectionizedLine.add()

      afterCharacter = true

    else
      if afterCharacter and not config.multiple
        sectionizedLine.after += tokenValue
      else
        sectionizedLine.before += tokenValue

  sectionizedLine.add()
  sectionizedLine.valid = afterCharacter

  return sectionizedLine

###
@name setOffsets
@description
Set alignment offset for each section
@param {Array.<Integer>} offsets
@param {SectionizedLine} sectionizedLine
###
setOffsets: (offsets, sectionizedLine) ->
  for section, i in sectionizedLine.sections
    if not offsets[i]? or section.offset > offsets[i]
      offsets[i] = section.offset

###
@name getSameIndentationRange
@description To get the start and end line number of the same indentation
@param {Editor} editor Active editor
@param {Integer} row Row to match
@returns {{range: Range, offset: Array}} An object with the start and end line
###
getSameIndentationRange: (editor, row, character) ->
  start = row - 1
  end   = row + 1

  sectionizedLines = {}
  tokenized   = @getTokenizedLineForBufferRow editor, row
  scope       = editor.getRootScopeDescriptor().getScopeChain()
  config      = operatorConfig.getConfig character, scope

  sectionizedLine = @parseTokenizedLine tokenized, character, config

  sectionizedLines[row] = sectionizedLine

  indent    = editor.indentationForBufferRow row
  total     = editor.getLineCount()
  hasPrefix = sectionizedLine.hasPrefix()

  offsets    = []
  startPoint = new Point(row, 0)
  endPoint   = new Point(row, Infinity)

  @setOffsets offsets, sectionizedLine

  while start > -1 or end < total
    if start > -1
      startLine = @getTokenizedLineForBufferRow editor, start

      if startLine? and editor.indentationForBufferRow(start) is indent
        if startLine.isComment()
          start -= 1

        else if (sectionizedLine = @parseTokenizedLine startLine, character, config) and sectionizedLine.isValid()
          sectionizedLines[start] = sectionizedLine
          @setOffsets offsets, sectionizedLine
          startPoint.row  = start
          hasPrefix       = true if not hasPrefix and sectionizedLine.hasPrefix()
          start          -= 1

        else
          start = -1

      else
        start = -1

    if end < total + 1
      endLine = @getTokenizedLineForBufferRow editor, end

      if endLine? and editor.indentationForBufferRow(end) is indent
        if endLine.isComment()
          end += 1

        else if (sectionizedLine = @parseTokenizedLine endLine, character, config) and sectionizedLine.isValid()
          sectionizedLines[end] = sectionizedLine
          @setOffsets offsets, sectionizedLine
          endPoint.row  = end
          hasPrefix     = true if not hasPrefix and sectionizedLine.hasPrefix()
          end          += 1

        else
          end = total + 1

      else
        end = total + 1

  if hasPrefix
    offsets = offsets.map (item) -> item + 1

  return {
    range:            new Range(startPoint, endPoint),
    offsets:          offsets
    sectionizedLines: sectionizedLines
  }

###
@name getTokenizedLineForBufferRow
@description
Get tokenized line
@param {Editor} editor
@param {Integer} row
@returns {Array}
###
getTokenizedLineForBufferRow: (editor, row) ->
  editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(row)

###
@name _formatTokenValue
@description
Convert invisibles in token to spaces or tabs
@param {Token} token
@param {Object} invisibles
@returns {String}
@private
###
_formatTokenValue: (token, invisibles) ->
  return "\t" if token.isHardTab

  return token.value unless token.hasInvisibleCharacters

  value = token.value

  if token.firstNonWhitespaceIndex?
    leading = value.substring(0, token.firstNonWhitespaceIndex)
    leading = @_formatInvisibleSpaces leading, invisibles
    value   = leading + value.substring(token.firstNonWhitespaceIndex)

  # To convert trailing whitespace invisible to whitespace
  if token.firstTrailingWhitespaceIndex?
    trailing = value.substring(token.firstTrailingWhitespaceIndex)
    trailing = @_formatInvisibleSpaces trailing, invisibles
    value    = value.substring(0, token.firstTrailingWhitespaceIndex) + trailing

  return value

###
@name _formatInvisibleSpaces
@description
Convert invisibles in string to text
@param {string} string
@param {Object} invisibles
@returns {String}
@private
###
_formatInvisibleSpaces: (string, invisibles) ->
  if invisibles.space?
    string = string.replace(new RegExp(invisibles.space, 'g'), " ")

  if invisibles.tab?
    string = string.replace(new RegExp(invisibles.tab, 'g'), "\t")

  return string
