{align} = require '../lib/vertical-align'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "VerticalAlign", ->
  activationPromise = null
  editor            = null
  buffer            = null

  beforeEach ->
    waitsForPromise ->
      activationPromise = atom.packages.activatePackage('language-coffee-script')

    runs ->
      editor = atom.project.openSync()
      buffer = editor.getBuffer()
      editor.setText """
        testing = "123"
        test = "321"

        someFn test

        test =
          foo: bar
          helloworld: test
          star: war

        longPrefix = "test"
        prefix += "hello"

        noSpace="work"
      """
      editor.setGrammar(atom.syntax.selectGrammar('test.js'))

  it "should align two lines correctly", ->
    editor.setCursorBufferPosition([0, 1])
    align(editor)
    expect(buffer.lineForRow(1)).toBe 'test    = "321"'

  it "should right correctly", ->
    editor.setCursorBufferPosition([6, 1])
    align editor
    expect(buffer.lineForRow(6)).toBe "  foo:        bar"

  it "should not align anything when cursor is not within string", ->
    editor.setCursorBufferPosition([3, 1])
    align(editor)
    expect(buffer.lineForRow(1)).toBe 'test = "321"'

  it "should handle prefix correctly", ->
    editor.setCursorBufferPosition([10, 1])
    align(editor)
    expect(buffer.lineForRow(11)).toBe 'prefix     += "hello"'

  it "should know how to align operator with no space", ->
    editor.setCursorBufferPosition([13, 1])
    align(editor)
    expect(buffer.lineForRow(13)).toBe 'noSpace = "work"'
