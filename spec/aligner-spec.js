'use strict';

const path = require('path');

describe("Aligner", () =>  {
  let editor, editorView, workspaceElement;

  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace);
    jasmine.attachToDOM(workspaceElement);
    atom.project.setPaths([path.join(__dirname, 'fixtures')]);

    waitsForPromise(() => {
      return atom.packages.activatePackage('aligner');
    });

    waitsForPromise(() => {
      return atom.packages.activatePackage('language-coffee-script');
    });

    waitsForPromise(() => {
      return atom.packages.activatePackage('aligner-coffeescript');
    });

    waitsForPromise(() => {
      return atom.workspace.open('aligner-sample.coffee');
    });

    runs(() => {
      editor = atom.workspace.getActiveTextEditor();
      editorView = atom.views.getView(editor);
    });
  });

  it("should align two lines correctly", () => {
    editor.setCursorBufferPosition([0, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(1)).toBe('test    = "321"');
  });

  it("should align correctly", () => {
    editor.setCursorBufferPosition([6, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(6)).toBe("  foo:        bar");
  });

  it("should ailgn correctly with config update", () => {
    editor.setCursorBufferPosition([6, 1]);
    atom.config.set('aligner-coffeescript.:-alignment', 'left');
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(6)).toBe("  foo       : bar");
  });

  it("should not align anything when cursor is not within string", () => {
    editor.setCursorBufferPosition([3, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(1)).toBe('test = "321"');
  });

  it("should handle prefix block correctly", () => {
    editor.setCursorBufferPosition([10, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(10)).toBe('longPrefix  = "test"');
  });

  it("should handle prefix correctly", () => {
    editor.setCursorBufferPosition([10, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(11)).toBe('prefix     += "hello"');
  });

  it("should know how to align operator with no space", () => {
    editor.setCursorBufferPosition([13, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(13)).toBe('noSpace = "work"');
  });

  it("should only align the first ':'", () => {
    editor.setCursorBufferPosition([16, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(16)).toBe('  hello:   {not: "world"}');
  });

  it("should align multiple items correctly", () => {
    editor.setCursorBufferPosition([20, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(21)).toBe('  ["abc"  , 19293, 102304, "more"]');
  });

  it("should align and keep the same indentation", () => {
    editor.setCursorBufferPosition([24, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(24)).toBe('    test    = "123"');
  });

  it("should align and keep the same indentation", () => {
    atom.config.set('editor.softTabs', false);
    editor.setCursorBufferPosition([24, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(24)).toBe('    test    = "123"');
  });

  it("should align multiple cursor correctly", () => {
    editor.setCursorBufferPosition([0, 1]);
    editor.addCursorAtBufferPosition([6, 1]);
    editor.addCursorAtBufferPosition([10, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(1)).toBe('test    = "321"');
    expect(editor.lineTextForBufferRow(6)).toBe("  foo:        bar");
    expect(editor.lineTextForBufferRow(10)).toBe('longPrefix  = "test"');
  });

  it("should align multiple blocks across comments", () => {
    editor.setCursorBufferPosition([31, 0]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(31)).toBe("  black:  '#000000'");
    expect(editor.lineTextForBufferRow(32)).toBe("  # block 2");
    expect(editor.lineTextForBufferRow(38)).toBe("  yellow: '#F6FF00'");
  });

  it("should align multiple blocks across comments when invisibes are on", () => {
    atom.config.set('editor.showInvisibles', true);
    atom.config.set('editor.softTabs', false);
    editor.setCursorBufferPosition([31, 0]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(31)).toBe("  black:  '#000000'");
    expect(editor.lineTextForBufferRow(32)).toBe("  # block 2");
    expect(editor.lineTextForBufferRow(38)).toBe("  yellow: '#F6FF00'");
  });

  it("should align multiple selections", () => {
    editor.setSelectedBufferRanges([[[30, 0], [32, 0]], [[6, 0], [8, 0]]]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(6)).toBe("  foo:        bar");
    expect(editor.lineTextForBufferRow(7)).toBe("  helloworld: test");
    expect(editor.lineTextForBufferRow(8)).toBe("  star:       war");
    expect(editor.lineTextForBufferRow(30)).toBe("  white:      '#FFFFFF'");
    expect(editor.lineTextForBufferRow(31)).toBe("  black:      '#000000'");
    expect(editor.lineTextForBufferRow(32)).toBe("  # block 2");
  });

  it("should maintain the same indentations after aligning", () => {
    editor.setSelectedBufferRanges([[[6, 2], [7, 0]]]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(6)).toBe("  foo:        bar");
    expect(editor.lineTextForBufferRow(7)).toBe("  helloworld: test");
  });

  it("should not align comments", () => {
    atom.config.set('aligner.alignComments', false);
    editor.setCursorBufferPosition([43, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(42)).toBe("  comment1: 'something' # first comment");
    expect(editor.lineTextForBufferRow(43)).toBe("  comment2: 'hi' # second comment");
    expect(editor.lineTextForBufferRow(44)).toBe("  # this is a comment only line");
    expect(editor.lineTextForBufferRow(45)).toBe("  comment3: 'world' # third comment");
  });

  it("should align comments", () => {
    atom.config.set('aligner.alignComments', true);
    editor.setCursorBufferPosition([42, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(42)).toBe("  comment1: 'something' # first comment");
    expect(editor.lineTextForBufferRow(43)).toBe("  comment2: 'hi'        # second comment");
    expect(editor.lineTextForBufferRow(44)).toBe("  # this is a comment only line");
    expect(editor.lineTextForBufferRow(45)).toBe("  comment3: 'world'     # third comment");
  });
});

describe("Aligning javascript", () => {
  let editor, editorView, workspaceElement;
  beforeEach(() => {
    workspaceElement = atom.views.getView(atom.workspace);
    jasmine.attachToDOM(workspaceElement);
    atom.project.setPaths([path.join(__dirname, 'fixtures')]);

    waitsForPromise(() => {
      return atom.packages.activatePackage('aligner');
    });

    waitsForPromise(() => {
      return atom.packages.activatePackage('language-javascript');
    });

    waitsForPromise(() => {
      return atom.packages.activatePackage('aligner-javascript');
    });

    waitsForPromise(() => {
      return atom.workspace.open('aligner-sample.js');
    });

    runs(() => {
      editor = atom.workspace.getActiveTextEditor();
      editorView = atom.views.getView(editor);
    });
  });

  afterEach(() => {
    atom.config.unset('aligner');
  });

  it("should align two lines correctly", () => {
    editor.setCursorBufferPosition([0, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(0)).toBe('var test   = "hello";');
  });

  it("should align ':' which isn't tokenized with scope", () => {
    editor.setCursorBufferPosition([5, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(5)).toBe('  "foo":   "bar"');
  });

  it("should align ',' correctly", () => {
    editor.setCursorBufferPosition([9, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(10)).toBe('  ["3"    , 2, 4]');
  });

  it("should not align comments", () => {
    atom.config.set('aligner.alignComments', false);
    editor.setCursorBufferPosition([13, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(13)).toBe("var comment1 = 'hello'; // first comment");
    expect(editor.lineTextForBufferRow(14)).toBe("var comment2 = /* inline comment */ 'world'; // second comment");
  });

  it("should align comments", function() {
    atom.config.set('aligner.alignComments', true);
    editor.setCursorBufferPosition([13, 1]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(13)).toBe("var comment1 = 'hello';                      // first comment");
    expect(editor.lineTextForBufferRow(14)).toBe("var comment2 = /* inline comment */ 'world'; // second comment");
  });

  it("should align trailing comment with or without operator in range", function() {
    atom.config.set('aligner.alignComments', true);
    editor.setSelectedBufferRange([[16, 1], [17, Infinity]]);
    atom.commands.dispatch(editorView, 'aligner:align');
    expect(editor.lineTextForBufferRow(16)).toBe("var comment3 = 'with trailing comment'; // some comment");
    expect(editor.lineTextForBufferRow(17)).toBe("var comment4;                           // some other comment");
  });
});
