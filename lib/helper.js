/**
 * @fileoverview Helper functions
 */

'use strict';

const operatorConfig = require('./operator-config');
const Point = require('atom').Point;
const Range = require('atom').Range;
const SectionizedLine = require('./sectionized-line');

function _traverseRanges (ranges, callback) {
  for (let rangeIndex = 0; rangeIndex < ranges.length; rangeIndex++) {
    let lines = ranges[rangeIndex].getRows();

    for (let i = 0; i < lines.length; i++) {
      let output = callback(lines[i], rangeIndex);
      if (output) return output;
    }
  }
}

/**
 * If token value is whitespaces only, return the same string. Otherwise, trim
 * all the whitespaces around the token value
 * @param {string} token
 * @returns {string}
 */
function _sanitizeTokenValue (token) {
  let trimmed = token.trim()
  if (token.length > 0 && !trimmed) {
    return token
  } else {
    return trimmed
  }
}

/**
 * Get the character to align based on text
 * @param {Editor} editor
 * @param {number} row
 * @param {string} character
 * @param {Object} characterConfig
 * @returns {String} Alignment character
 */
function getAlignCharacter (editor, row, character, characterConfig) {
  let tokenized = getTokenizedLineForBufferRow(editor, row);
  let languageScope = editor.getRootScopeDescriptor().getScopeChain() || 'base';

  if (!tokenized) return null;

  for (let i = 0; i < tokenized.tokens.length; i++) {
    let token = tokenized.tokens[i];
    let tokenValue = _sanitizeTokenValue(token.value);

    let config = operatorConfig.getConfig(tokenValue, languageScope);
    if (!config) {
      continue;
    }

    for (let j = 0; j < token.scopes.length; j++) {
      let doesScopeMatch = token.scopes[j].match(config.scope) != null
      // NOTE: Return alignment character if scope matches and,
      // - there is no original character
      // - there is an original character and can align with the current character
      if (doesScopeMatch &&
          (!character || operatorConfig.canAlignWith(character, tokenValue, characterConfig))) {
        return tokenValue;
      }
    }
  }
}

/**
 * Get the character to align within certain ranges
 * @param {Editor} editor
 * @param {Array.<Range>} ranges
 * @returns {String} Alignment character
 */
function getAlignCharacterInRanges (editor, ranges) {
  return _traverseRanges(ranges, (line) => {
    let character = this.getAlignCharacter(editor, line);
    if (character) {
      return character
    }
  });
}

/**
 * Get alignment offset and sectionizedLines based on character and selections
 * @param {Editor} editor
 * @param {String} character
 * @param {Array.<Range>} ranges
 * @returns {{offsets:<Array>, sectionizedLines:<Array>}}
 */
function getOffsetsAndSectionizedLines (editor, character, ranges) {
  let scope = editor.getRootScopeDescriptor().getScopeChain();
  let offsets = [];
  let sectionizedLines = [];

  _traverseRanges(ranges, (line, rangeIndex) => {
    let tokenized       = getTokenizedLineForBufferRow(editor, line);
    let config          = operatorConfig.getConfig(character, scope);
    let sectionizedLine = parseTokenizedLine(tokenized, character, config);

    if (!sectionizedLines[rangeIndex]) {
      sectionizedLines[rangeIndex] = {};
    }

    sectionizedLines[rangeIndex][line] = sectionizedLine;

    if (sectionizedLine.isValid()) {
      setOffsets(offsets, sectionizedLine);
    }
  });

  return {
    offsets,
    sectionizedLines
  }
}

/**
 * Parsing line with operator
 * @param {Object} tokenizedLine Tokenized line object from editor display buffer
 * @param {String} character Character to align
 * @param {Object} config Character config
 * @returns {SectionizedLine} Information about the tokenized line including text before character,
 *                 text after character, character prefix, offset and if the line is
 *                 valid
 */
function parseTokenizedLine (tokenizedLine, character, config) {
  let afterCharacter       = false;
  let sectionizedLine      = new SectionizedLine();
  let trailingCommentIndex = -1;

  // Only align trailing comments, not full line comments
  if (!tokenizedLine.isComment() && atom.config.get('aligner.alignComments')) {
    // traverse backward for trailing comments
    for (let index = tokenizedLine.tokens.length - 1; index >= 0; index--) {
      let token = tokenizedLine.tokens[index];

      if (token.matchesScopeSelector('comment')) {
        sectionizedLine.trailingComment = _formatTokenValue(token, tokenizedLine.invisibles) +
            sectionizedLine.trailingComment;
      } else {
        trailingCommentIndex = index + 1;
        break;
      }
    }
  }

  for (let index = 0; index < tokenizedLine.tokens.length; index++) {
    let token = tokenizedLine.tokens[index];

    // exit out of the loop when processing trailing comments
    if (index == trailingCommentIndex) break

    let tokenValue = _formatTokenValue(token, tokenizedLine.invisibles);

    if (operatorConfig.canAlignWith(character, _sanitizeTokenValue(tokenValue), config) && (!afterCharacter || config.multiple)) {
      sectionizedLine.prefix = operatorConfig.isPrefixed(_sanitizeTokenValue(tokenValue), config);

      if (config.multiple) {
        sectionizedLine.add();
      }

      afterCharacter = true;

    } else {
      if (afterCharacter && !config.multiple) {
        sectionizedLine.after += tokenValue;
      } else {
        sectionizedLine.before += tokenValue;
      }
    }
  }

  sectionizedLine.add();
  sectionizedLine.valid = afterCharacter;

  return sectionizedLine;
}

/**
 * Set alignment offset for each section
 * @param {Array.<Integer>} offsets
 * @param {SectionizedLine} sectionizedLine
 */
function setOffsets (offsets, sectionizedLine) {
  sectionizedLine.sections.forEach((section, i) => {
    if (offsets[i] == null || section.offset > offsets[i]) {
      offsets[i] = section.offset;
    }
  });
}

/**
 * To get the start and end line number of the same indentation
 * @param {Editor} editor Active editor
 * @param {Integer} row Row to match
 * @param {string} character
 * @return {{range: Range, offset: Array}} An object with the start and end line
 */
function getSameIndentationRange (editor, row, character) {
  let start = row - 1;
  let end = row + 1;

  let sectionizedLines = {};
  let tokenized        = getTokenizedLineForBufferRow(editor, row);
  let scope            = editor.getRootScopeDescriptor().getScopeChain();
  let config           = operatorConfig.getConfig(character, scope);

  let sectionizedLine = parseTokenizedLine(tokenized, character, config);

  sectionizedLines[row] = sectionizedLine;

  let indent    = editor.indentationForBufferRow(row);
  let total     = editor.getLineCount();
  let hasPrefix = sectionizedLine.hasPrefix();

  let offsets    = [];
  let startPoint = new Point(row, 0);
  let endPoint   = new Point(row, Infinity);

  setOffsets(offsets, sectionizedLine);

  while (start > -1 || end < total) {
    if (start > -1) {
      let startLine = getTokenizedLineForBufferRow(editor, start);

      if (startLine && editor.indentationForBufferRow(start) == indent) {
        let sectionizedLine = parseTokenizedLine(startLine, character, config);
        if (startLine.isComment()) {
          sectionizedLines[start] = sectionizedLine;
          start -= 1;

        } else if (sectionizedLine && sectionizedLine.isValid()) {
          sectionizedLines[start] = sectionizedLine;
          setOffsets(offsets, sectionizedLine);

          startPoint.row = start;
          if (!hasPrefix && sectionizedLine.hasPrefix()) {
            hasPrefix = true;
          }
          start -= 1;

        } else {
          start = -1;
        }

      } else {
        start = -1;
      }
    }

    if (end < total + 1) {
      let endLine = getTokenizedLineForBufferRow(editor, end);

      if (endLine && editor.indentationForBufferRow(end) == indent) {
        let sectionizedLine = parseTokenizedLine(endLine, character, config);
        if (endLine.isComment()) {
          sectionizedLines[end] = sectionizedLine;
          end += 1;

        } else if (sectionizedLine && sectionizedLine.isValid()) {
          sectionizedLines[end] = sectionizedLine;
          setOffsets(offsets, sectionizedLine);

          endPoint.row = end;
          if (!hasPrefix && sectionizedLine.hasPrefix()) {
            hasPrefix = true;
          }
          end += 1;

        } else {
          end = total + 1;
        }

      } else {
        end = total + 1;
      }
    }
  }

  if (hasPrefix) {
    offsets = offsets.map((item) => item + 1);
  }

  return {
    range:            new Range(startPoint, endPoint),
    offsets:          offsets,
    sectionizedLines: sectionizedLines
  }
}

/**
 * Get tokenized line
 * @param {Editor} editor
 * @param {Integer} row
 * @return {Array}
 */
function getTokenizedLineForBufferRow (editor, row) {
  // displayBuffer is deprecated in 1.9
  let tokenizedBuffer = editor.tokenizedBuffer || editor.displayBuffer.tokenizedBuffer

  return tokenizedBuffer.tokenizedLineForRow(row);
}

/**
 * Convert invisibles in token to spaces or tabs
 * @param {Token} token
 * @param {Object} invisibles
 * @return {String}
 * @private
 */
function _formatTokenValue (token, invisibles) {
  if (token.isHardTab) return '\t';
  if (!token.hasInvisibleCharacters) return token.value;

  let value = token.value;

  if (token.firstNonWhitespaceIndex != null) {
    let leading = value.substring(0, token.firstNonWhitespaceIndex);
    leading = _formatInvisibleSpaces(leading, invisibles);
    value = leading + value.substring(token.firstNonWhitespaceIndex);
  }

  // To convert trailing whitespace invisible to whitespace
  if (token.firstTrailingWhitespaceIndex != null) {
    let trailing = value.substring(token.firstTrailingWhitespaceIndex);
    trailing = _formatInvisibleSpaces(trailing, invisibles);
    value = value.substring(0, token.firstTrailingWhitespaceIndex) + trailing;
  }

  return value;
}

/**
 * Convert invisibles in string to text
 * @param {string} string
 * @param {Object} invisibles
 * @return {String}
 * @private
 */
function _formatInvisibleSpaces (string, invisibles) {
  if (invisibles.space != null) {
    string = string.replace(new RegExp(invisibles.space, 'g'), ' ');
  }

  if (invisibles.tab != null) {
    string = string.replace(new RegExp(invisibles.tab, 'g'), '\t');
  }

  return string
}

module.exports = {
  getAlignCharacter,
  getAlignCharacterInRanges,
  getOffsetsAndSectionizedLines,
  parseTokenizedLine,
  setOffsets,
  getSameIndentationRange,
  getTokenizedLineForBufferRow,
  _formatTokenValue,
  _formatInvisibleSpaces,
  _sanitizeTokenValue
}
