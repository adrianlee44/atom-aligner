/**
 * @fileoverview
 */

'use strict';

const Section = require('./section');

module.exports =
class SectionizedLine {
  constructor() {
    this._prefix = false;
    this._valid = false;

    this._trailingComment = '';

    this._currentSection = new Section();
    this._sections = [];
  }

  get before() {
    return this._currentSection.before;
  }

  set before(value) {
    this._currentSection.before = value;
  }

  get after() {
    return this._currentSection.after;
  }

  set after(value) {
    this._currentSection.after = value;
  }

  get trailingComment() {
    return this._trailingComment;
  }

  set trailingComment(value) {
    this._trailingComment = value;
  }

  set prefix(value) {
    this._prefix = value;
  }

  set valid(value) {
    this._valid = value;
  }

  get sections() {
    return this._sections;
  }

  get length() {
    return this._sections.length;
  }

  add() {
    this._currentSection.sanitize();
    this._sections.push(this._currentSection);

    this._currentSection = new Section();
  }

  hasPrefix() {
    return !!this._prefix;
  }

  isValid() {
    return this._valid;
  }
}
