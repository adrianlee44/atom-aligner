operatorConfig = require './operator-config'
helper         = require './helper'

align = (editor) ->
  if !editor.hasMultipleCursors()
    # Get cursor row and text
    origRow = editor.getCursorBufferPosition().row
    text    = editor.lineForBufferRow origRow

    # Get alignment character
    character = helper.getAlignCharacter text

    if character
      indentRange = helper.getSameIndentationRange editor, origRow, character
      config      = operatorConfig[character]
      regex       = helper.getOffsetRegex character
      textBlock   = ""

      for row in [indentRange.start..indentRange.end]
        lineText = editor.lineForBufferRow row
        match    = lineText.match(regex)
        # Character length up to the first whitespace before/after alignment character
        currentOffset = match[1].length

        # Whitespace around alignment character
        spaceBefore = match[2].length
        spaceAfter  = match[4].length

        operator = match[3]

        # New whitespaces to add before/after alignment character
        newSpace = ("" for i in [0..indentRange.offset - currentOffset]).join " "

        leftSpace   = if config.alignment is "left" then newSpace else ""
        leftSpace  += " " if config.leftSpace
        rightSpace  = if config.alignment is "right" then newSpace else ""
        rightSpace += " " if config.rightSpace

        newText  = lineText.substr(0, currentOffset)
        newText += leftSpace + operator + rightSpace
        newText += lineText.substr(
          currentOffset + spaceBefore + operator.length + spaceAfter
        )
        textBlock += "#{newText}\n"

      # Replace the whole block
      editor.setTextInBufferRange([[indentRange.start, 0], [indentRange.end + 1, 0]], textBlock)

      # Update the cursor to the end of the original line
      editor.setCursorBufferPosition [origRow, editor.lineForBufferRow(origRow).length]


module.exports =
  align:    align
  activate: ->
    atom.workspaceView.command 'vertical-align:align', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      align(editor)
