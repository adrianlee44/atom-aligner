operatorConfig  = require './operator-config'
helper          = require './helper'
providerManager = require './provider-manager'
formatter       = require './formatter'
configs         = require '../config'
extend          = require 'extend'
{CompositeDisposable} = require 'atom'

class Aligner
  config: operatorConfig.getAtomConfig()

  ###
  @param {Editor} editor
  ###
  align: (editor) ->
    rangesWithContent = []
    for range in editor.getSelectedBufferRanges()
      # if the range is just a cursor
      if range.isEmpty()
        @alignAtRow(editor, range.start.row)

      else
        rangesWithContent.push range

    if rangesWithContent.length > 0
      @alignRanges(editor, rangesWithContent)

    return

  alignAtRow: (editor, row) ->
    character = helper.getAlignCharacter editor, row
    return unless character

    {range, offset} = helper.getSameIndentationRange editor, row, character
    formatter.formatRange editor, range, character, offset

  alignRanges: (editor, ranges) ->
    character = helper.getAlignCharacterInRanges editor, ranges
    return unless character

    offsets = helper.getOffsets editor, character, ranges
    for range in ranges
      formatter.formatRange editor, range, character, offsets

  activate: ->
    @disposables = new CompositeDisposable
    @disposables.add atom.config.observe 'aligner', (value) ->
      operatorConfig.updateConfigWithAtom 'aligner', value

    @disposables.add atom.commands.add 'atom-text-editor', 'aligner:align', =>
      @align atom.workspace.getActiveTextEditor()

    alignerConfig = extend true, {}, configs
    extend true, alignerConfig.config, atom.config.get('aligner')
    @disposables.add operatorConfig.add 'aligner', alignerConfig

    @disposables.add atom.config.observe 'aligner', (value) ->
      operatorConfig.updateConfigWithAtom 'aligner', value

  deactivate: ->
    @disposables.dispose()
    @disposables = null

  registerProviders: (provider) ->
    # Register with providerManager
    @disposables.add providerManager.register provider

module.exports = new Aligner()
