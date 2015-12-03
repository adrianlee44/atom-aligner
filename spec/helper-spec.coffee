helper         = require '../lib/helper'
operatorConfig = require '../lib/operator-config'
path           = require 'path'
configs        = require '../config'
{Range} = require 'atom'

describe "Helper", ->
  editor = null
  config = null

  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'fixtures')])

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.packages.activatePackage('aligner')

    waitsForPromise ->
      atom.workspace.open('helper-sample.coffee').then (o) ->
        editor = o

    runs ->
      config = operatorConfig.getConfig '='

  describe "getSameIndentationRange", ->
    describe "should include comments", ->
      [range, offset] = []

      beforeEach ->
        {range, offset} = helper.getSameIndentationRange editor, 23, ':'

      it "should get the valid start row", ->
        expect(range.start.row).toBe 22

      it "should get the valid end row", ->
        expect(range.end.row).toBe 32

      it "should get the valid offset", ->
        expect(offset).toEqual [8]

    describe "should return valid range object when cursor is in the middle", ->
      [range, offset] = []
      beforeEach ->
        {range, offset} = helper.getSameIndentationRange editor, 2, "="

      it "should get the valid start row", ->
        expect(range.start.row).toBe 1

      it "should get the valid end row", ->
        expect(range.end.row).toBe 3

      it "should get the valid offset", ->
        expect(offset).toEqual [7]

    describe "should return valid range object when cursor is on the last line", ->
      [range, offset] = []
      beforeEach ->
        {range, offset} = helper.getSameIndentationRange editor, 3, "="

      it "should get the valid start row", ->
        expect(range.start.row).toBe 1

      it "should get the valid end row", ->
        expect(range.end.row).toBe 3

      it "should get the valid offset", ->
        expect(offset).toEqual [7]

    describe "should return valid range object when cursor is on the first line", ->
      [range, offset] = []
      beforeEach ->
        {range, offset} = helper.getSameIndentationRange editor, 1, "="

      it "should get the valid start row", ->
        expect(range.start.row).toBe 1

      it "should get the valid end row", ->
        expect(range.end.row).toBe 3

      it "should get the valid offset", ->
        expect(offset).toEqual [7]

  describe "getAlignCharacter", ->
    grammar = null
    beforeEach ->
      grammar = editor.getGrammar()

    it "should get the = character", ->
      character = helper.getAlignCharacter editor, 1

      expect(character).toBe "="

    it "should get the : character", ->
      character = helper.getAlignCharacter editor, 7

      expect(character).toBe ":"

    it "should get the , character", ->
      character = helper.getAlignCharacter editor, 13

      expect(character).toBe ","

    it "should not find anything", ->
      character = helper.getAlignCharacter editor, 4

      expect(character).not.toBeDefined()

  describe "getAlignCharacterInRanges", ->
    grammar = null
    beforeEach ->
      grammar = editor.getGrammar()

    it "should get the = character", ->
      ranges = [new Range([1,0], [3, 0])]
      character = helper.getAlignCharacterInRanges editor, ranges

      expect(character).toBe "="

    it "should get the : character", ->
      ranges = [new Range([7,0], [9, 0])]
      character = helper.getAlignCharacterInRanges editor, ranges

      expect(character).toBe ":"

    it "should get the , character", ->
      ranges = [new Range([13,0], [15, 0])]
      character = helper.getAlignCharacterInRanges editor, ranges

      expect(character).toBe ","

    it "should not find anything", ->
      ranges = [new Range([34,0], [35, 0])]
      character = helper.getAlignCharacterInRanges editor, ranges

      expect(character).not.toBeDefined()

  describe "parseTokenizedLine", ->
    grammar = null
    beforeEach ->
      grammar = editor.getGrammar()

    describe "parsing a valid line", ->
      output = null
      beforeEach ->
        line = grammar.tokenizeLine editor.lineTextForBufferRow 2
        output = helper.parseTokenizedLine line, "=", config

      it "should get the text before = with right trimmed", ->
        expect(output[0].before).toBe "  hello"

      it "should get the text after = with left trimmed", ->
        expect(output[0].after).toBe '"world"'

      it "should get the offset", ->
        expect(output[0].offset).toBe 7

      it "should return no prefix", ->
        expect(output.prefix).toBe false

      it "should show the line is valid", ->
        expect(output.valid).toBeTruthy()

    describe "parsing an invalid line", ->
      output = null
      beforeEach ->
        grammar = editor.getGrammar()
        line    = grammar.tokenizeLine editor.lineTextForBufferRow 4
        output  = helper.parseTokenizedLine line, "=", config

      it "should show the line is invalid", ->
        expect(output.valid).toBeFalsy()

    describe "parsing a line with prefix", ->
      output = null
      beforeEach ->
        grammar = editor.getGrammar()
        line    = grammar.tokenizeLine editor.lineTextForBufferRow 9
        output  = helper.parseTokenizedLine line, "-=", config

      it "should show the line is valid", ->
        expect(output.valid).toBeTruthy()

      it "should return the correct prefix", ->
        expect(output.prefix).toBe true

      it "should get the text before = with right trimmed", ->
        expect(output[0].before).toBe "prefix"

      it "should get the text after = with left trimmed", ->
        expect(output[0].after).toBe '1'

      it "should get the offset", ->
        expect(output[0].offset).toBe 6

    describe "parsing a line with leading and/or trailing whitespaces", ->
      output = null
      beforeEach ->
        atom.config.set 'editor.showInvisibles', true

      afterEach ->
        atom.config.set 'editor.showInvisibles', false
        atom.config.set 'editor.softTabs', true

      it "should include leading whitespaces", ->
        line   = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(17)
        output = helper.parseTokenizedLine line, "=", config

        expect(output[0].before).toBe "        testing"
        expect(output[0].after).toBe "123"

      it "should include trailing whitespaces", ->
        line   = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(18)
        output = helper.parseTokenizedLine line, "=", config

        expect(output[0].before).toBe "        test"
        expect(output[0].after).toBe "'abc'      "

      it "should handle tabs correctly", ->
        line   = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(36)
        output = helper.parseTokenizedLine line, "=", config

        expect(output[0].before).toBe "				testing"
        expect(output[0].after).toBe "123"

    describe "parsing a line with multiple characters", ->
      output = null
      beforeEach ->
        commaConfig =
          leftSpace:  true
          rightSpace: false
          scope:      "delimiter"
          multiple:
            number:
              alignment: "left"
            string:
              alignment: "right"
        grammar = editor.getGrammar()
        line    = grammar.tokenizeLine editor.lineTextForBufferRow 13
        output  = helper.parseTokenizedLine line, ",", commaConfig

      it "should show the line is valid", ->
        expect(output.valid).toBeTruthy()

      it "should parsed out 3 items", ->
        expect(output.length).toBe 3

      it "should not have any prefix", ->
        expect(output.prefix).toBe false

      it "should have content in before for all items", ->
        content = true
        output.forEach (item) ->
          content = false if item.before.length is 0

        expect(content).toBeTruthy()
