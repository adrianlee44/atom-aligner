'use strict';

const formatter = require('../lib/formatter');

describe("Formatter", () => {
  describe('buildWhitespaces', () => {
    it('should build the correct number of whitespaces', () => {
      let output = formatter.buildWhitespaces(4);
      expect(output).toBe('    ');
    });

    it('should build an empty string', () => {
      expect(formatter.buildWhitespaces(0)).toBe('');
      expect(formatter.buildWhitespaces()).toBe('');
      expect(formatter.buildWhitespaces(-1)).toBe('');
    });
  });
});
