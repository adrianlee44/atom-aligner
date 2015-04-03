operatorConfig = require './operator-config'
helper         = require './helper'
{Disposable}   = require 'atom'
providerManager = require './provider-manager'

class Aligner
  config: operatorConfig.getAtomConfig()

  align: (editor) ->
    if !editor.hasMultipleCursors()
      # Get cursor row and text
      origRow   = editor.getCursorBufferPosition().row
      tokenized = helper.getTokenizedLineForBufferRow(editor, origRow)
      scope     = editor.getRootScopeDescriptor().getScopeChain()

      # Get alignment character
      character = helper.getTokenizedAlignCharacter tokenized.tokens, scope

      if character
        indentLevel = editor.indentationForBufferRow origRow
        indentRange = helper.getSameIndentationRange editor, origRow, character
        config      = operatorConfig.getConfig character, scope
        textBlock   = ""

        for row in [indentRange.start..indentRange.end]
          tokenizedLine = helper.getTokenizedLineForBufferRow(editor, row)
          lineCharacter = helper.getTokenizedAlignCharacter tokenizedLine.tokens, scope
          parsed        = helper.parseTokenizedLine tokenizedLine, lineCharacter, config

          # Construct new line
          currentLine = editor.buildIndentString indentLevel

          for parsedItem, i in parsed
            offset = parsedItem.offset + (if parsed.prefix then 1 else 0)

            # New whitespaces to add before/after alignment character
            newSpace = ""
            for j in [1..indentRange.offset[i] - offset] by 1
              newSpace += " "

            if config.multiple
              type      = if isNaN(+parsedItem.before) then "string" else "number"
              alignment = config.multiple[type]?.alignment or "left"

            else
              alignment = config.alignment

            leftSpace  = if alignment is "left" then newSpace else ""
            leftSpace += " " if config.leftSpace

            rightSpace  = if alignment is "right" then newSpace else ""
            rightSpace += " " if config.rightSpace


            if config.multiple
              if i is 0
                currentLine += parsedItem.before
              else
                currentLine += leftSpace + parsedItem.before.trim()

              currentLine += rightSpace + lineCharacter unless i is parsed.length - 1

            else
              currentLine += parsedItem.before
              currentLine += leftSpace + lineCharacter + rightSpace
              currentLine += parsedItem.after

          textBlock += "#{currentLine}\n"

        # Replace the whole block
        editor.setTextInBufferRange([[indentRange.start, 0], [indentRange.end + 1, 0]], textBlock)

        # Update the cursor to the end of the original line
        editor.setCursorBufferPosition [origRow, editor.lineTextForBufferRow(origRow).length]

  activate: ->
    atom.config.observe 'aligner', (value) ->
      operatorConfig.updateConfigWithAtom value
    atom.commands.add 'atom-text-editor', 'aligner:align', =>
      @align atom.workspace.getActiveTextEditor()

  registerProviders: (provider) ->
    # Register with providerManager
    providerManager.register provider

    new Disposable ->
      # Unregister provider from providerManager
      providerManager.unregister provider

module.exports = new Aligner()
