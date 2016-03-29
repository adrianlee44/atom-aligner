/**
 * @fileoverview Main aligner file
 */

'use strict';

const operatorConfig = require('./operator-config');
const helper = require('./helper');
const providerManager = require('./provider-manager');
const formatter = require('./formatter');
const configs = require('../config');
const extend = require('extend');
const CompositeDisposable = require('atom').CompositeDisposable;

class Aligner {
  constructor() {}

  get config() {
    return operatorConfig.getAtomConfig();
  }

  /**
   * @param {Editor} editor
   */
  align(editor) {
    const rangesWithContent = [];

    editor.getSelectedBufferRanges().forEach((range) => {
      // if the range is just a cursor
      if (range.isEmpty()) {
        this.alignAtRow(editor, range.start.row);
      } else {
        rangesWithContent.push(range);
      }
    });

    if (rangesWithContent.length > 0) {
      this.alignRanges(editor, rangesWithContent);
    }
  }

  alignAtRow(editor, row) {
    const character = helper.getAlignCharacter(editor, row);

    if (!character) return;

    let output = helper.getSameIndentationRange(editor, row, character);
    let range = output.range;
    let offsets = output.offsets;
    let sectionizedLines = output.sectionizedLines;

    formatter.formatRange(editor, range, character, offsets, sectionizedLines);
  }

  alignRanges(editor, ranges) {
    const character = helper.getAlignCharacterInRanges(editor, ranges);

    if (!character) return;

    let output = helper.getOffsetsAndSectionizedLines(editor, character, ranges);
    let offsets = output.offsets;
    let sectionizedLines = output.sectionizedLines;

    ranges.forEach((range, rangeIndex) => {
      formatter.formatRange(editor, range, character, offsets, sectionizedLines[rangeIndex]);
    });
  }

  activate() {
    this.disposables = new CompositeDisposable();

    this.disposables.add(atom.config.observe('aligner', (value) => {
      operatorConfig.updateConfigWithAtom('aligner', value);
    }));

    this.disposables.add(atom.commands.add('atom-text-editor', 'aligner:align', () => {
      this.align(atom.workspace.getActiveTextEditor());
    }));

    let alignerConfig = extend(true, {}, configs);
    extend(true, alignerConfig.config, atom.config.get('aligner'));
    this.disposables.add(operatorConfig.add('aligner', alignerConfig));
  }

  deactivate() {
    this.disposables.dispose();
    this.disposables = null;
  }

  registerProviders(provider) {
    // Register with providerManager
    this.disposables.add(providerManager.register(provider));
  }
}

module.exports = new Aligner();
