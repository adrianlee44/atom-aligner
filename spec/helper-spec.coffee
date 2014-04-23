helper = require '../lib/helper'

describe "Helper", ->
  editor = null

  beforeEach ->
    runs ->
      editor = atom.project.openSync('helper-sample.coffee')
      buffer = editor.buffer
      editor.setGrammar(atom.syntax.selectGrammar('text.coffee'))

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

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
        expect(output.offset).toEqual [7]

    describe "should return valid range object when cursor is on the last line", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 3, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toEqual [7]

    describe "should return valid range object when cursor is on the first line", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 1, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toEqual [7]

  describe "getTokenizedAlignCharacter", ->
    it "should get the = character", ->
      line      = editor.displayBuffer.lineForRow 1
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).toBe "="

    it "should get the : character", ->
      line      = editor.displayBuffer.lineForRow 7
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).toBe ":"

    it "should get the , character", ->
      line      = editor.displayBuffer.lineForRow 13
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).toBe ","

    it "should not find anything", ->
      line      = editor.displayBuffer.lineForRow 4
      character = helper.getTokenizedAlignCharacter line.tokens

      expect(character).not.toBeDefined()

  describe "parseTokenizedLine", ->

    describe "parsing a valid line", ->
      output = null
      beforeEach ->
        line = editor.displayBuffer.lineForRow 2
        output = helper.parseTokenizedLine line, "="

      it "should get the text before = with right trimmed", ->
        expect(output[0].before).toBe "  hello"

      it "should get the text after = with left trimmed", ->
        expect(output[0].after).toBe '"world"'

      it "should get the offset", ->
        expect(output[0].offset).toBe 7

      it "should return no prefix", ->
        expect(output.prefix).toBe null

      it "should show the line is valid", ->
        expect(output.valid).toBeTruthy()

    describe "parsing an invalid line", ->
      output = null
      beforeEach ->
        line = editor.displayBuffer.lineForRow 4
        output = helper.parseTokenizedLine line, "="

      it "should show the line is invalid", ->
        expect(output.valid).toBeFalsy()

    describe "parsing a line with prefix", ->
      output = null
      beforeEach ->
        line   = editor.displayBuffer.lineForRow 9
        output = helper.parseTokenizedLine line, "="

      it "should show the line is valid", ->
        expect(output.valid).toBeTruthy()

      it "should return the correct prefix", ->
        expect(output.prefix).toBe "-"

      it "should get the text before = with right trimmed", ->
        expect(output[0].before).toBe "prefix"

      it "should get the text after = with left trimmed", ->
        expect(output[0].after).toBe '1'

      it "should get the offset", ->
        expect(output[0].offset).toBe 6

    describe "parsing a line with multiple characters", ->
      output = null
      beforeEach ->
        line   = editor.displayBuffer.lineForRow 13
        output = helper.parseTokenizedLine line, ","

      it "should show the line is valid", ->
        expect(output.valid).toBeTruthy()

      it "should parsed out 3 items", ->
        expect(output.length).toBe 3

      it "should not have any prefix", ->
        expect(output.prefix).toBe null

      it "should have content in before for all items", ->
        content = true
        output.forEach (item) ->
          content = false if item.before.length is 0

        expect(content).toBeTruthy()
