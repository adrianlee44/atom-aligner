operatorConfig = require './operator-config'
helper         = require './helper'

class Aligner
  align: (editor) ->
    if !editor.hasMultipleCursors()
      # Get cursor row and text
      origRow = editor.getCursorBufferPosition().row

      grammar = editor.getGrammar()

      tokenized = grammar.tokenizeLine editor.lineTextForBufferRow origRow

      # Get alignment character
      character = helper.getTokenizedAlignCharacter tokenized.tokens

      if character
        indentRange = helper.getSameIndentationRange editor, origRow, character
        config      = operatorConfig.getConfig character
        textBlock   = ""

        for row in [indentRange.start..indentRange.end]
          tokenizedLine = grammar.tokenizeLine editor.lineTextForBufferRow row
          lineCharacter = helper.getTokenizedAlignCharacter tokenizedLine.tokens
          parsed        = helper.parseTokenizedLine tokenizedLine, lineCharacter

          for parsedItem, i in parsed
            offset = parsedItem.offset + (if parsed.prefix then 1 else 0)

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

            rightSpace  = if alignment is "right" then newSpace else ""
            rightSpace += " " if config.rightSpace

            if config.multiple
              if i is 0
                textBlock += parsedItem.before
              else
                textBlock += leftSpace + parsedItem.before.trim()

              textBlock += rightSpace + lineCharacter unless i is parsed.length - 1

            else
              textBlock += parsedItem.before
              textBlock += leftSpace + lineCharacter + rightSpace
              textBlock += parsedItem.after

          textBlock += "\n"

        # Replace the whole block
        editor.setTextInBufferRange([[indentRange.start, 0], [indentRange.end + 1, 0]], textBlock)

        # Update the cursor to the end of the original line
        editor.setCursorBufferPosition [origRow, editor.lineTextForBufferRow(origRow).length]

  activate: ->
    atom.commands.add 'atom-text-editor', 'vertical-align:align', =>
      @align atom.workspace.getActiveTextEditor()

module.exports = new Aligner()
