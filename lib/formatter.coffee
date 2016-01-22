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
  @param {Object} parsedLines
  ###
  formatRange: (editor, range, character, offsets, parsedLines) ->
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

      parsed      = parsedLines[currentRow]
      currentLine = ""

      for parsedItem, i in parsed
        offset = parsedItem.offset + (if parsed.prefix then 1 else 0)

        # New whitespaces to add before/after alignment character
        newSpace = ""
        for j in [1..offsets[i] - offset] by 1
          newSpace += " "

        if config.multiple
          type      = if isNaN(+parsedItem.before) then "string" else "number"
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
          before       = parsedItem.before
          before       = before.trim() if i > 0
          currentLine += rightSpace + before
          currentLine += leftSpace + lineCharacter unless i is parsed.length - 1

        else
          currentLine += parsedItem.before
          currentLine += leftSpace + lineCharacter + rightSpace
          currentLine += parsedItem.after

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
