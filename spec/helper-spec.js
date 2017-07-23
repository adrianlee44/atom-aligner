'use strict';

const helper = require('../lib/helper');
const operatorConfig = require('../lib/operator-config');
const path = require('path');
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
      return atom.packages.activatePackage('aligner-coffeescript');
    });

    waitsForPromise(() => {
      return atom.workspace.open('helper-sample.coffee')
      .then((o) => {
        editor = o;
      });
    });

    runs(() => {
      config = operatorConfig.getConfig('=', editor);
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
      let offsets, range, sectionizedLines;
      beforeEach(() => {
        const output = helper.getSameIndentationRange(editor, 23, ':');
        range = output.range;
        offsets = output.offsets;
        sectionizedLines = output.sectionizedLines;
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

      it("should have sectionizedLine for all lines", () => {
        for (let i = 22; i <= 32; i++) {
          expect(sectionizedLines[i]).toBeDefined()
        }
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

    it("should get the = character", () => {
      let config = operatorConfig.getConfig("+=", editor);

      const character = helper.getAlignCharacter(editor, 1, "+=", config);
      expect(character).toBe("=");
    });

    it("should not get the = character", () => {
      let config = operatorConfig.getConfig(":", editor);

      const character = helper.getAlignCharacter(editor, 1, ":", config);
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
    describe("parsing a valid line", () => {
      let output;
      beforeEach(() => {
        const line = editor.tokenizedBuffer.tokenizedLineForRow(2);
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

    describe("not parse a line with the same character but not match scope", () => {
      let output;

      beforeEach(() => {
        let scssEditor;

        waitsForPromise(() => {
          return atom.packages.activatePackage('aligner-scss');
        });

        waitsForPromise(() => {
          return atom.workspace.open('test.scss')
          .then((o) => {
            scssEditor = o;
          });
        });

        runs(() => {
          const line = scssEditor.tokenizedBuffer.tokenizedLineForRow(3);
          output = helper.parseTokenizedLine(line, ':', {
            alignment: 'right',
            leftSpace: false,
            rightSpace: true,
            scope: 'key-value|property-name|operator'
          });
        });
      });

      it('should show the line is invalid', () => {
        expect(output.isValid()).toBe(false);
      });
    })

    describe("parsing a full line comment", () => {
      let output;
      beforeEach(() => {
        const line = editor.tokenizedBuffer.tokenizedLineForRow(38);
        output = helper.parseTokenizedLine(line, "=", config);
      });

      it("should get all the text in before", () => {
        expect(output.sections[0].before).toBe("# full line comment");
      });

      it("should get nothing in after", () => {
        expect(output.sections[0].after).toBe('');
      });

      it("should show the line is invalid", () => {
        expect(output.isValid()).toBe(false);
      });
    });

    describe("parsing an invalid line", () => {
      let output;
      beforeEach(() => {
        const line = editor.tokenizedBuffer.tokenizedLineForRow(4);
        output = helper.parseTokenizedLine(line, "=", config);
      });

      it("should show the line is invalid", () => {
        expect(output.isValid()).toBe(false);
      });
    });

    describe("parsing a line with prefix", () => {
      let output;
      beforeEach(() => {
        const line = editor.tokenizedBuffer.tokenizedLineForRow(9);
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
      let output, tokenizedBuffer;
      beforeEach(() => {
        atom.config.set('editor.showInvisibles', true);

        tokenizedBuffer = editor.tokenizedBuffer || editor.displayBuffer.tokenizedBuffer;
      });

      afterEach(() => {
        atom.config.set('editor.showInvisibles', false);
        atom.config.set('editor.softTabs', true);
      });


      it("should include leading whitespaces", () => {
        const line = tokenizedBuffer.tokenizedLineForRow(17);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("        testing");
        expect(output.sections[0].after).toBe("123");
      });

      it("should include trailing whitespaces", () => {
        const line = tokenizedBuffer.tokenizedLineForRow(18);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("        test");
        expect(output.sections[0].after).toBe("'abc'      ");
      });

      it("should handle tabs correctly", () => {
        const line = tokenizedBuffer.tokenizedLineForRow(36);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("				testing");
        expect(output.sections[0].after).toBe("123");
      });
    });

    describe("parsing a line with leading whitespaces and hiding invisibles", () => {
      let output, tokenizedBuffer;
      beforeEach(() => {
        atom.config.set('editor.showInvisibles', false);
        atom.config.set('editor.softTabs', false);
        atom.config.set('editor.tabType', 'hard');

        tokenizedBuffer = editor.tokenizedBuffer || editor.displayBuffer.tokenizedBuffer;
      });

      afterEach(() => {
        atom.config.unset('editor');
      });

      it("should handle tabs correctly", () => {
        const line = tokenizedBuffer.tokenizedLineForRow(36);
        output = helper.parseTokenizedLine(line, "=", config);
        expect(output.sections[0].before).toBe("				testing");
        expect(output.sections[0].after).toBe("123");
      });

      it("should not be affected by tab length", () => {
        atom.config.set('editor.tabLength', 4);
        const line = tokenizedBuffer.tokenizedLineForRow(36);
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
        const line = editor.tokenizedBuffer.tokenizedLineForRow(13);
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

  describe("isTokenizedLineCommentOnly", () => {
    it("should return false when there is no comment", () => {
      const line = editor.tokenizedBuffer.tokenizedLineForRow(2);
      expect(helper.isTokenizedLineCommentOnly(line)).toBe(false);
    });

    it("should return false when there is trailing comment", () => {
      const line = editor.tokenizedBuffer.tokenizedLineForRow(40);
      expect(helper.isTokenizedLineCommentOnly(line)).toBe(false);
    });

    it("should return true when the full line is comment", () => {
      const line = editor.tokenizedBuffer.tokenizedLineForRow(38);
      expect(helper.isTokenizedLineCommentOnly(line)).toBe(true);
    });

    it("should return false when the line is empty", () => {
      const line = editor.tokenizedBuffer.tokenizedLineForRow(39);
      expect(helper.isTokenizedLineCommentOnly(line)).toBe(false);
    });
  })
});
