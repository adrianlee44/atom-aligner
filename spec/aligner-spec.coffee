aligner = require '../lib/main'

describe "Aligner", ->
  editor = null
  buffer = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

    waitsForPromise ->
      atom.project.open('aligner-sample.coffee').then (o) ->
        editor = o

    runs ->
      buffer = editor.buffer

  it "should align two lines correctly", ->
    editor.setCursorBufferPosition([0, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(1)).toBe 'test    = "321"'

  it "should right correctly", ->
    editor.setCursorBufferPosition([6, 1])
    aligner.align editor
    expect(buffer.lineForRow(6)).toBe "  foo:        bar"

  it "should not align anything when cursor is not within string", ->
    editor.setCursorBufferPosition([3, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(1)).toBe 'test = "321"'

  it "should handle prefix block correctly", ->
    editor.setCursorBufferPosition([10, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(10)).toBe 'longPrefix  = "test"'

  it "should handle prefix correctly", ->
    editor.setCursorBufferPosition([10, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(11)).toBe 'prefix     += "hello"'

  it "should know how to align operator with no space", ->
    editor.setCursorBufferPosition([13, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(13)).toBe 'noSpace = "work"'

  it "should only align the first ':'", ->
    editor.setCursorBufferPosition([16, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(16)).toBe '  hello:   {not: "world"}'

  it "should align multiple items correctly", ->
    editor.setCursorBufferPosition([20, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(21)).toBe '  ["abc"  , 19293, 102304, "more"]'

  it "should align and keep the same indentation", ->
    editor.setCursorBufferPosition([24, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(24)).toBe '    test    = "123"'

  it "should align and keep the same indentation", ->
    atom.config.set 'editor.softTabs', false
    editor.setCursorBufferPosition([24, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(24)).toBe '    test    = "123"'

  it "should align multiple cursor correctly", ->
    editor.setCursorBufferPosition([0, 1])
    editor.addCursorAtBufferPosition([6, 1])
    editor.addCursorAtBufferPosition([10, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(1)).toBe 'test    = "321"'
    expect(buffer.lineForRow(6)).toBe "  foo:        bar"
    expect(buffer.lineForRow(10)).toBe 'longPrefix  = "test"'

describe "Aligning javascript", ->
  editor = null
  buffer = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.project.open('aligner-sample.js').then (o) ->
        editor = o

    runs ->
      buffer = editor.buffer
      editor.setGrammar(atom.grammars.selectGrammar('test.js'))

  it "should align two lines correctly", ->
    editor.setCursorBufferPosition([0, 1])
    aligner.align(editor)
    expect(buffer.lineForRow(0)).toBe 'var test   = "hello";'

  it "should align ':' which isn't tokenized with scope", ->
    editor.setCursorBufferPosition([5,1])
    aligner.align(editor)
    expect(buffer.lineForRow(5)).toBe '  "foo":   "bar"'

  it "should align ',' correctly", ->
    editor.setCursorBufferPosition [9, 1]
    aligner.align(editor)
    expect(buffer.lineForRow(10)).toBe '  ["3"    , 2, 4]'
