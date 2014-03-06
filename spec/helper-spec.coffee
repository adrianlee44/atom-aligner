helper = require '../lib/helper'

describe "Helper", ->
  describe "getOffsetRegex", ->
    it "should create regex for '='", ->
      regex = helper.getOffsetRegex "="
      expect(regex.toString()).toBe("/(\\s*[^=\\s]+)(\\s*)([\\+\\-&\\|<>\\!~%\\/\\*\\.]?=)(\\s*).*/")

    it "should create regex for ':'", ->
      regex = helper.getOffsetRegex ":"
      expect(regex.toString()).toBe("/(\\s*[^:\\s]+)(\\s*)([]?:)(\\s*).*/")

  describe "getSameIndentationRange", ->
    editor = null

    beforeEach ->
      runs ->
        editor = atom.project.openSync()
        buffer = editor.getBuffer()
        editor.setText """
          test = ->
            foo = "bar"
            hello = "world"
            star = "war"
        """
        editor.setGrammar(atom.syntax.selectGrammar('text.js'))

    describe "should return valid range object when cursor is in the middle", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 2, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toBe 7

    describe "should return valid range object when cursor is on the last line", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 3, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toBe 7

    describe "should return valid range object when cursor is on the first line", ->
      output = null
      beforeEach ->
        output = helper.getSameIndentationRange editor, 1, "="

      it "should get the valid start row", ->
        expect(output.start).toBe 1

      it "should get the valid end row", ->
        expect(output.end).toBe 3

      it "should get the valid offset", ->
        expect(output.offset).toBe 7

  describe "getAlignCharacter", ->
    it "should get '='", ->
      output = helper.getAlignCharacter "testing = foo"
      expect(output).toBe "="

    it "should get ':'", ->
      output = helper.getAlignCharacter "foo: bar"
      expect(output).toBe ":"
