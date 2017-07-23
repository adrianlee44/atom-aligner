/**
 * @name formatter
 * @fileoverview Format and align text
 */

'use strict';

const helper         = require('./helper');
const operatorConfig = require('./operator-config');

module.exports = {
  /**
   * @name formatRange
   * @description
   * Align character within a certain range of text in the editor
   * @param {Editor} editor
   * @param {Range} range
   * @param {string} character
   * @param {Array} offsets
   * @param {Object} sectionizedLines
  */
  formatRange: function (editor, range, character, offsets, sectionizedLines) {
    let config    = operatorConfig.getConfig(character, editor);
    let lines     = [];
    let maxLength = 0;

    range.getRows().forEach(function(currentRow) {
      let currentLine = '';
      const tokenizedLine = helper.getTokenizedLineForBufferRow(editor, currentRow);
      const lineCharacter = helper.getAlignCharacter(editor, currentRow, character, config);
      const sectionizedLine = sectionizedLines[currentRow];

      if (!sectionizedLine) return;

      if (!lineCharacter || helper.isTokenizedLineCommentOnly(tokenizedLine)) {
        sectionizedLine.sections.forEach((function(section) {
          currentLine += section.before;
        }));
        lines.push(currentLine);
        return;
      }

      sectionizedLine.sections.forEach(function(section, index) {
        const offset = section.offset + (sectionizedLine.hasPrefix() ? 1 : 0);

        // New whitespaces to add before/after alignment character
        const newSpace = this.buildWhitespaces(offsets[index] - offset);

        let alignment;
        if (config.multiple) {
          const type = isNaN(+section.before) ? 'string' : 'number';
          alignment = (config.multiple[type] && config.multiple[type].alignment) || 'left';
        } else {
          alignment = config.alignment;
        }

        let leftSpace = alignment == 'left' ? newSpace : '';
        if (config.leftSpace) leftSpace += ' ';

        let rightSpace = alignment == 'right' ? newSpace : '';

        // ignore right space config when aligning multiple on the same line
        if (config.rightSpace && !(config.multiple && index == 0)) {
          rightSpace += ' ';
        }

        if (config.multiple) {
          // NOTE: rightSpace here instead of after lineCharacter to get the proper
          // offset for the token
          let before = section.before;
          if (index > 0) before = before.trim();
          currentLine += rightSpace + before;

          if (index != sectionizedLine.length - 1)
            currentLine += leftSpace + lineCharacter;
        } else {
          currentLine += section.before;
          currentLine += leftSpace + lineCharacter + rightSpace;
          currentLine += section.after
        }
      }, this);

      if (currentLine.length > maxLength) {
        maxLength = currentLine.length;
      }

      lines.push(currentLine);
    }, this);

    if (atom.config.get('aligner.alignComments')) {
      lines.forEach(function(line, index) {
        const sectionizedLine = sectionizedLines[range.start.row + index];

        // sectionizedLine does not exist for comment only line
        if (sectionizedLine && sectionizedLine.trailingComment) {
          lines[index] += this.buildWhitespaces(maxLength - line.length) + sectionizedLine.trailingComment;
        }
      }, this);
    }

    // Set the first line to the start of the line
    range.start.column = 0;
    // Set the last line column to the end
    range.end.column = Infinity;

    // Replace the whole block
    editor.setTextInBufferRange(range, lines.join('\n'));

    // Update the cursor to the end of the original line
    editor.setCursorBufferPosition(range.end);
  },

  /**
   * @name buildWhitespaces
   * @description
   * Build a string with n whitespaces
   * @param {number} length
   * @returns {string}
  */
  buildWhitespaces: function (length) {
    if (length == 0) return '';

    let newSpace = '';
    for (let i = 0; i < length; i++) {
      newSpace += ' ';
    }

    return newSpace;
  }
}
