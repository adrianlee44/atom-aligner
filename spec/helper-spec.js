'use strict';

const helper = require('../lib/helper');
const operatorConfig = require('../lib/operator-config');
const path = require('path');
const configs = require('../config');
const Range = require('atom').Range;

describe("Helper", () => {
  let editor = null;
  let config = null;
  beforeEach(() => {
    atom.project.setPaths([path.join(__dirname, 'fixtures')]);

    waitsForPromise(() => {
      return atom.packages.activatePackage('language-coffee-script');
    });

    waitsForPromise(() => {
      return atom.packages.activatePackage('aligner');
    });

    waitsForPromise(() => {
      return atom.workspace.open('helper-sample.coffee')
      .then((o) => {
        editor = o;
      });
    });

    runs(() => {
      config = operatorConfig.getConfig('=');
    });
  });

  describe('_sanitizeTokenValue', () => {
    it('should trim correctly', () => {
      expect(helper._sanitizeTokenValue('  ')).toBe('  ');
      expect(helper._sanitizeTokenValue(' ')).toBe(' ');
      expect(helper._sanitizeTokenValue('')).toBe('');
      expect(helper._sanitizeTokenValue(', ')).toBe(',');
      expect(helper._sanitizeTokenValue('+=')).toBe('+=');
      expect(helper._sanitizeTokenValue('=>')).toBe('=>');
    });
  });

  describe("getSameIndentationRange", () => {
    describe("should include comments", () => {
      let offsets, range;
      beforeEach(() => {
        const output = helper.getSameIndentationRange(editor, 23, ':');
        range = output.range;
        offsets = output.offsets;
      });

      it("should get the valid start row", () => {
        expect(range.start.row).toBe(22);
      });

      it("should get the valid end row", () => {
        expect(range.end.row).toBe(32);
      });

      it("should get the valid offset", () => {
        expect(offsets).toEqual([8]);
      });
    });

    describe("should return valid range object when cursor is in the middle", () => {
      let offsets, range;
      beforeEach(() => {
        const output = helper.getSameIndentationRange(editor, 2, "=");
        range = output.range;
        offsets = output.offsets;
      });

      it("should get the valid start row", () => {
        expect(range.start.row).toBe(1);
      });

      it("should get the valid end row", () => {
        expect(range.end.row).toBe(3);
      });

      it("should get the valid offset", () => {
        expect(offsets).toEqual([7]);
      });
    });

    describe("should return valid range object when cursor is on the last line", () => {
      let offsets, range;
      beforeEach(() => {
        let output = helper.getSameIndentationRange(editor, 3, "=");
        range = output.range;
        offsets = output.offsets;
      });

      it("should get the valid start row", () => {
        expect(range.start.row).toBe(1);
      });

      it("should get the valid end row", () => {
        expect(range.end.row).toBe(3);
      });

      it("should get the valid offset", () => {
        expect(offsets).toEqual([7]);
      });
    });

    describe("should return valid range object when cursor is on the first line", () => {
      let offsets, range;
      beforeEach(() => {
        let output = helper.getSameIndentationRange(editor, 1, "=");
        range = output.range;
        offsets = output.offsets;
      });

      it("should get the valid start row", () => {
        expect(range.start.row).toBe(1);
      });

      it("should get the valid end row", () => {
        expect(range.end.row).toBe(3);
      });

      it("should get the valid offset", () => {
        expect(offsets).toEqual([7]);
      });
    });
  });

  describe("getAlignCharacter", () => {
    let grammar;
    beforeEach(() => {
      grammar = editor.getGrammar();
    });

    it("should get the = character", () => {
      const character = helper.getAlignCharacter(editor, 1);
      expect(character).toBe("=");
    });

    it("should get the : character", () => {
      const character = helper.getAlignCharacter(editor, 7);
      expect(character).toBe(":");
    });

    it("should get the , character", () => {
      const character = helper.getAlignCharacter(editor, 13);
      expect(character).toBe(",");
    });

    it("should not find anything", () => {
      const character = helper.getAlignCharacter(editor, 4);
      expect(character).not.toBeDefined();
    });
  });

  describe("getAlignCharacterInRanges", () => {
    let grammar;
    beforeEach(() => {
      grammar = editor.getGrammar();
    });

    it("should get the = character", () => {
      const ranges = [new Range([1, 0], [3, 0])];
      const character = helper.getAlignCharacterInRanges(editor, ranges);
      expect(character).toBe("=");
    });

    it("should get the : character", () => {
      const ranges = [new Range([7, 0], [9, 0])];
      const character = helper.getAlignCharacterInRanges(editor, ranges);
      expect(character).toBe(":");
    });

    it("should get the , character", () => {
      const ranges = [new Range([13, 0], [15, 0])];
      const character = helper.getAlignCharacterInRanges(editor, ranges);
      expect(character).toBe(",");
    });

    it("should not find anything", () => {
      const ranges = [new Range([34, 0], [35, 0])];
      const character = helper.getAlignCharacterInRanges(editor, ranges);
      expect(character).not.toBeDefined();
    });
  });

  describe("parseTokenizedLine", () => {
    let grammar;
    beforeEach(() => {
      grammar = editor.getGrammar();
    });

    describe("parsing a valid line", () => {
      let output;
      beforeEach(() => {
        const line = grammar.tokenizeLine(editor.lineTextForBufferRow(2));
        output = helper.parseTokenizedLine(line, "=", config);
      });

      it("should get the text before = with right trimmed", () => {
        expect(output.sections[0].before).toBe("  hello");
      });

      it("should get the text after = with left trimmed", () => {
        expect(output.sections[0].after).toBe('"world"');
      });

      it("should get the offset", () => {
        expect(output.sections[0].offset).toBe(7);
      });

      it("should return no prefix", () => {
        expect(output.hasPrefix()).toBe(false);
      });

      it("should show the line is valid", () => {
        expect(output.isValid()).toBe(true);
      });
    });

    describe("parsing an invalid line", () => {
      let output;
      beforeEach(() => {
        grammar = editor.getGrammar();
        const line = grammar.tokenizeLine(editor.lineTextForBufferRow(4));
        output = helper.parseTokenizedLine(line, "=", config);
      });

      it("should show the line is invalid", () => {
        expect(output.isValid()).toBe(false);
      });
    });

    describe("parsing a line with prefix", () => {
      let output;
      beforeEach(() => {
        grammar = editor.getGrammar();
        const line = grammar.tokenizeLine(editor.lineTextForBufferRow(9));
        output = helper.parseTokenizedLine(line, "-=", config);
      });

      it("should show the line is valid", () => {
        expect(output.isValid()).toBe(true);
      });

      it("should return the correct prefix", () => {
        expect(output.hasPrefix()).toBe(true);
      });

      it("should get the text before = with right trimmed", () => {
        expect(output.sections[0].before).toBe("prefix");
      });

      it("should get the text after = with left trimmed", () => {
        expect(output.sections[0].after).toBe('1');
      });

      it("should get the offset", () => {
        expect(output.sections[0].offset).toBe(6);
      });
    });

    describe("parsing a line with leading and/or trailing whitespaces", () => {
      let output;
      beforeEach(() => {
        atom.config.set('editor.showInvisibles', true);
      });

      afterEach(() => {
        atom.config.set('editor.showInvisibles', false);
        atom.config.set('editor.softTabs', true);
      });


      it("should include leading whitespaces", () => {
        const line = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(17);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("        testing");
        expect(output.sections[0].after).toBe("123");
      });

      it("should include trailing whitespaces", () => {
        const line = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(18);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("        test");
        expect(output.sections[0].after).toBe("'abc'      ");
      });

      it("should handle tabs correctly", () => {
        const line = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(36);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("				testing");
        expect(output.sections[0].after).toBe("123");
      });
    });

    describe("parsing a line with leading whitespaces and hiding invisibles", () => {
      let output;
      beforeEach(() => {
        atom.config.set('editor.showInvisibles', false);
        atom.config.set('editor.softTabs', false);
        atom.config.set('editor.tabType', 'hard');
      });

      afterEach(() => {
        atom.config.unset('editor');
      });

      it("should handle tabs correctly", () => {
        const line = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(36);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("				testing");
        expect(output.sections[0].after).toBe("123");
      });

      it("should not be affected by tab length", () => {
        atom.config.set('editor.tabLength', 4);
        const line = editor.displayBuffer.tokenizedBuffer.tokenizedLineForRow(36);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("				testing");
        expect(output.sections[0].after).toBe("123");
      });
    });

    describe("parsing a line with multiple characters", () => {
      let output;
      beforeEach(() => {
        const commaConfig = {
          leftSpace: true,
          rightSpace: false,
          scope: "delimiter",
          multiple: {
            number: {
              alignment: "left"
            },
            string: {
              alignment: "right"
            }
          }
        };
        grammar = editor.getGrammar();
        const line = grammar.tokenizeLine(editor.lineTextForBufferRow(13));
        output = helper.parseTokenizedLine(line, ",", commaConfig);
      });

      it("should show the line is valid", () => {
        expect(output.isValid()).toBe(true);
      });

      it("should parsed out 3 items", () => {
        expect(output.sections.length).toBe(3);
      });

      it("should not have any prefix", () => {
        expect(output.hasPrefix()).toBe(false);
      });

      it("should have content in before for all items", () => {
        let content = true;
        output.sections.forEach((item) => {
          if (item.before.length === 0) {
            content = false;
          }
        });
        expect(content).toBeTruthy();
      });
    });
  });
});
