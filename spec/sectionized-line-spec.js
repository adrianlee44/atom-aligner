'use strict';

const SectionizedLine = require('../lib/sectionized-line');
const Section = require('../lib/section')

describe('SectionizedLine', function() {
  let testSectionizedLine;

  beforeEach(function() {
    testSectionizedLine = new SectionizedLine();
  });

  it('should initialize correctly', function() {
    expect(testSectionizedLine._prefix).toBe(false);
    expect(testSectionizedLine._valid).toBe(false);

    expect(testSectionizedLine._currentSection).toBeDefined();
    expect(testSectionizedLine._currentSection instanceof Section).toBe(true);

    expect(testSectionizedLine._sections.length).toBe(0);
  });

  it('should get and set before of the current section', function() {
    testSectionizedLine.before = 'before text';

    expect(testSectionizedLine.before).toBe('before text');

    const section = testSectionizedLine._currentSection;
    expect(section.before).toBe('before text');
  });

  it('should get and set after of the current section', function() {
    testSectionizedLine.after = 'after text';

    expect(testSectionizedLine.after).toBe('after text');

    const section = testSectionizedLine._currentSection;
    expect(section.after).toBe('after text');
  });

  it('should get and set prefix', function() {
    testSectionizedLine.prefix = true;

    expect(testSectionizedLine._prefix).toBe(true);
    expect(testSectionizedLine.hasPrefix()).toBe(true);
  });

  it('should get and set valid', function() {
    testSectionizedLine.valid = true;

    expect(testSectionizedLine._valid).toBe(true);
    expect(testSectionizedLine.isValid()).toBe(true);
  });

  it('should get sections', function() {
    const sections = [{}, {}, {}];

    testSectionizedLine._sections = sections;

    expect(testSectionizedLine.sections).toBe(sections);
  });

  it('should add to sections and trim strings', function() {
    const currentSection = testSectionizedLine._currentSection;
    testSectionizedLine.before = '  before text  ';
    testSectionizedLine.after = '  after text  ';

    testSectionizedLine.add();

    expect(currentSection.before).toBe('  before text');
    expect(currentSection.after).toBe('after text  ');
    expect(testSectionizedLine.sections.length).toBe(1);
    expect(testSectionizedLine.sections[0]).toBe(currentSection);

    expect(testSectionizedLine._currentSection).not.toBe(currentSection);
    expect(testSectionizedLine._currentSection instanceof Section).toBe(true);
  });

  it('should add to sections and get the correct length', function() {
    testSectionizedLine.add();
    testSectionizedLine.add();

    expect(testSectionizedLine.sections.length).toBe(2);
    expect(testSectionizedLine.length).toBe(2);
  });
});
