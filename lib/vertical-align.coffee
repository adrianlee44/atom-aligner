operatorConfig = require './operator-config'
helper         = require './helper'

align = (editor) ->
  if !editor.hasMultipleCursors()
    # Get cursor row and text
    origRow = editor.getCursorBufferPosition().row

    grammar = editor.getGrammar()

    tokenized = grammar.tokenizeLine editor.lineTextForBufferRow origRow

    # Get alignment character
    character = helper.getTokenizedAlignCharacter tokenized.tokens

    if character
      indentRange = helper.getSameIndentationRange editor, origRow, character
      config      = operatorConfig[character]
      textBlock = ""

      for row in [indentRange.start..indentRange.end]
        tokenizedLine = grammar.tokenizeLine editor.lineTextForBufferRow row
        parsed        = helper.parseTokenizedLine tokenizedLine, character

        for parsedItem, i in parsed
          offset = parsedItem.offset + (if parsed.prefix? then 1 else 0)

          # New whitespaces to add before/after alignment character
          newSpace = ""
          for j in [1..indentRange.offset[i] - offset] by 1
            newSpace += " "

          if config.multiple
            type      = if isNaN(+parsedItem.before) then "string" else "number"
            alignment = config.multiple[type].alignment

          else
            alignment = config.alignment

          leftSpace  = if alignment is "left" then newSpace else ""
          leftSpace += " " if config.leftSpace
          leftSpace += parsed.prefix if parsed.prefix?

          rightSpace  = if alignment is "right" then newSpace else ""
          rightSpace += " " if config.rightSpace

          if config.multiple
            textBlock += leftSpace + parsedItem.before
            textBlock += rightSpace + character unless i is parsed.length - 1

          else
            textBlock += parsedItem.before
            textBlock += leftSpace + character + rightSpace
            textBlock += parsedItem.after

        textBlock += "\n"

      # Replace the whole block
      editor.setTextInBufferRange([[indentRange.start, 0], [indentRange.end + 1, 0]], textBlock)

      # Update the cursor to the end of the original line
      editor.setCursorBufferPosition [origRow, editor.lineTextForBufferRow(origRow).length]


module.exports =
  align:    align
  activate: ->
    atom.workspaceView.command 'vertical-align:align', '.editor', ->
      editor = atom.workspace.getActivePaneItem()
      align(editor)
