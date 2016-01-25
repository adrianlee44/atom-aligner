/**
 * @fileoverview
 */

'use strict';

module.exports =
class section {
  constructor() {
    this._before = '';
    this._after = '';

    this._offset = 0;
  }

  get before() {
    return this._before;
  }

  set before(value) {
    this._before = value;
    this._offset = this._before.length;
  }

  get after() {
    return this._after;
  }

  set after(value) {
    this._after = value;
  }

  get offset() {
    return this._offset;
  }

  set offset(value) {
    this._offset = value;
  }

  sanitize() {
    this.before = this.before.trimRight();
    this.after = this.after.trimLeft();
  }
}
