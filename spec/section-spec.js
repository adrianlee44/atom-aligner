'use strict';

const Section = require('../lib/section');

describe('Section', function() {
  let testSection;

  beforeEach(function() {
    testSection = new Section();
  });

  it('should initialize empty strings and values', function() {
    expect(testSection._before).toBe('');
    expect(testSection._after).toBe('');
    expect(testSection._offset).toBe(0);
  });

  it('should get and set before', function () {
    testSection.before = 'hi';
    expect(testSection.before).toBe('hi');

    testSection.before += ', testing';
    expect(testSection.before).toBe('hi, testing');
    expect(testSection.offset).toBe(11)
  });

  it('should get and set after', function () {
    testSection.after = 'hi';
    expect(testSection.after).toBe('hi');

    testSection.after += ', testing';
    expect(testSection.after).toBe('hi, testing');
  });

  it('should trim before and after', function () {
    testSection.before = '  this is before  ';
    testSection.after = '  this is after  ';

    expect(testSection.offset).toBe(18);

    testSection.sanitize();

    expect(testSection.before).toBe('  this is before');
    expect(testSection.after).toBe('this is after  ');
    expect(testSection.offset).toBe(16);
  });
});
