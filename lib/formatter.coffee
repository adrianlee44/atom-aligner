helper         = require './helper'
operatorConfig = require './operator-config'

module.exports =
  ###
  @name formatRange
  @description
  Align character within a certain range of text in the editor
  @param {Editor} editor
  @param {Range} range
  @param {string} character
  @param {Array} offsets
  @param {Object} sectionizedLines
  ###
  formatRange: (editor, range, character, offsets, sectionizedLines) ->
    scope     = editor.getRootScopeDescriptor().getScopeChain()
    config    = operatorConfig.getConfig character, scope
    textBlock = ""

    for currentRow in range.getRows()
      tokenizedLine = helper.getTokenizedLineForBufferRow(editor, currentRow)
      lineCharacter = helper.getAlignCharacter editor, currentRow
      canAlignWith  = operatorConfig.canAlignWith character, lineCharacter, config

      if not lineCharacter or not canAlignWith or tokenizedLine.isComment()
        textBlock += editor.lineTextForBufferRow(currentRow)
        textBlock += "\n" unless currentRow is range.end.row
        continue

      sectionizedLine = sectionizedLines[currentRow]
      currentLine     = ""

      for section, i in sectionizedLine.sections
        offset = section.offset + (if sectionizedLine.hasPrefix() then 1 else 0)

        # New whitespaces to add before/after alignment character
        newSpace = @buildWhitespaces(offsets[i] - offset)

        if config.multiple
          type      = if isNaN(+section.before) then "string" else "number"
          alignment = config.multiple[type]?.alignment or "left"

        else
          alignment = config.alignment

        leftSpace  = if alignment is "left" then newSpace else ""
        leftSpace += " " if config.leftSpace

        rightSpace = if alignment is "right" then newSpace else ""
        # ignore right space config when aligning multiple on the same line
        if config.rightSpace and not (config.multiple and i is 0)
          rightSpace += " "

        if config.multiple
          # NOTE: rightSpace here instead of after lineCharacter to get the proper
          # offset for the token
          before       = section.before
          before       = before.trim() if i > 0 # not the first one
          currentLine += rightSpace + before
          currentLine += leftSpace + lineCharacter unless i is sectionizedLine.length - 1

        else
          currentLine += section.before
          currentLine += leftSpace + lineCharacter + rightSpace
          currentLine += section.after

      textBlock += currentLine
      textBlock += "\n" unless currentRow is range.end.row

    # Set the first line to the start of the line
    range.start.column = 0
    # Set the last line column to the end
    range.end.column = Infinity

    # Replace the whole block
    editor.setTextInBufferRange(range, textBlock)

    # Update the cursor to the end of the original line
    editor.setCursorBufferPosition range.end

    return

  ###
  @name buildWhitespaces
  @description
  Build a string with n whitespaces
  @param {number} length
  @returns {string}
  ###
  buildWhitespaces: (length) ->
    return '' unless length > 0

    newSpace = ""
    for j in [0...length] by 1
      newSpace += " "

    return newSpace
