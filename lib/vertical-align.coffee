operatorConfig = require './operator-config'
helper         = require './helper'

align = (editor) ->
  if !editor.hasMultipleCursors()
    # Get cursor row and text
    origRow   = editor.getCursorBufferPosition().row
    tokenized = editor.displayBuffer.lineForRow origRow

    # Get alignment character
    character = helper.getTokenizedAlignCharacter tokenized.tokens

    if character
      indentRange = helper.getSameIndentationRange editor, origRow, character
      config      = operatorConfig[character]
      textBlock   = ""

      for row in [indentRange.start..indentRange.end]
        tokenizedLine = editor.displayBuffer.lineForRow row
        parsed        = helper.parseTokenizedLine tokenizedLine, character
        offset        = parsed.offset + (if parsed.prefix? then 1 else 0)

        # New whitespaces to add before/after alignment character
        newSpace = ""
        for i in [1..indentRange.offset - offset] by 1
          newSpace += " "

        leftSpace  = if config.alignment is "left" then newSpace else ""
        leftSpace += " " if config.leftSpace
        leftSpace += parsed.prefix if parsed.prefix?

        rightSpace  = if config.alignment is "right" then newSpace else ""
        rightSpace += " " if config.rightSpace

        textBlock += parsed.before
        textBlock += leftSpace + character + rightSpace
        textBlock += "#{parsed.after}\n"

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
