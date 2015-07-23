helper         = require '../lib/helper'
operatorConfig = require '../lib/operator-config'

describe "Helper", ->
  editor = null
  config = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.project.open('helper-sample.coffee').then (o) ->
        editor = o

    runs ->
      buffer = editor.buffer
      config = operatorConfig.getConfig '='

  describe "getSameIndentationRange", ->
    describe "should return valid range object when cursor is in the middle", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 2, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toEqual [5]

    describe "should return valid range object when cursor is on the last line", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 3, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toEqual [5]

    describe "should return valid range object when cursor is on the first line", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 1, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toEqual [5]

  describe "getTokenizedAlignCharacter", ->
    grammar = null
    beforeEach ->
      grammar = editor.getGrammar()

    it "should get the = character", ->
      line      = grammar.tokenizeLine editor.lineTextForBufferRow 1
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).toBe "="

    it "should get the : character", ->
      line      = grammar.tokenizeLine editor.lineTextForBufferRow 7
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).toBe ":"

    it "should get the , character", ->
      line      = grammar.tokenizeLine editor.lineTextForBufferRow 13
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).toBe ","

    it "should not find anything", ->
      line      = grammar.tokenizeLine editor.lineTextForBufferRow 4
      character = helper.getTokenizedAlignCharacter line.tokens

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

      it "should not include leading whitespaces", ->
        line   = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(17)
        output = helper.parseTokenizedLine line, "=", config

        expect(output[0].before).toBe "testing"
        expect(output[0].after).toBe "123"

      it "should include trailing whitespaces", ->
        line   = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(18)
        output = helper.parseTokenizedLine line, "=", config

        expect(output[0].before).toBe "test"
        expect(output[0].after).toBe "'abc'      "

      it "should handle tabs correctly", ->
        atom.config.set 'editor.softTabs', false
        line   = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(18)
        output = helper.parseTokenizedLine line, "=", config

        expect(output[0].before).toBe "test"
        expect(output[0].after).toBe "'abc'      "

    describe "parse a line with different tab length", ->
      beforeEach ->
        atom.config.set 'editor.tabLength', 4

      afterEach ->
        atom.config.set 'editor.tabLength', 2

      it 'should parse leading whitespace correctly', ->
        line = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(6)
        output = helper.parseTokenizedLine line, ':', config
        expect(output[0].before).toBe "test"
        expect(output[0].after).toBe "\"123\""

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
