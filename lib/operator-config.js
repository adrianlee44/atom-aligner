/**
 * @fileoverview Operator Config - Handling language specific operator configuration
 */

'use strict';

const extend = require('extend');
const Disposable = require('atom').Disposable;

/**
 * Example for '='
 * "=": {
 *   "alignment":  "left",
 *   "leftSpace":  true,
 *   "rightSpace": true,
 *   "prefixes":   ["+", "-", "&", "|", "<", ">", "!", "~", "%", "/", "*", "."],
 *   "scope":      "operator|assignment"
 * }
 * `alignWith` and `prefixed` get added if `prefixes` key exist
 * alignWith {array} Array of other operators that should be aligned with
 * prefixed {array} Array of operators that have prefixes
*/

class OperatorConfig {
  constructor() {
    this.settings = {};
  }

  /**
   * Add/register provider config
   * @param {string} id Provider id
   * @param {Object} provider Provider object
   * @return {Disposable}
   */
  add(id, provider) {
    if (this.settings[id]) {
     console.error(`${id} has already been activated`);

    } else {
     let allConfigs = extend({}, provider.config, provider.privateConfig);
     this.settings[id] = this.convertAtomConfig(allConfigs);

     this.settings[id].selector = provider.selector ? provider.selector.slice(0) : '';

     this.initializePrefix(this.settings[id]);
    }

    return new Disposable(() => {
     this.remove(id);
    });
  }

  remove(id) {
    if (this.settings[id]) {
     delete this.settings[id];
    }
  }

  removeAll() {
    this.settings = {};
  }

  /**
  * Update aligner setting based on config.json format
  * @param {string} packageId
  * @param {object} newConfig
  */
  updateSetting(packageId, newConfig) {
    packageId = packageId || 'aligner';

    if (this.settings[packageId]) {
      extend(true, this.settings[packageId], newConfig);
    }
  }

  initializePrefix(originalConfigs) {
    for (let key in originalConfigs) {
      let config = originalConfigs[key];
      if (key != 'selector' && config.prefixes) {
        config.alignWith = [key];
        config.prefixed = [];

        config.prefixes.forEach((prefix) => {
          let keyWithPrefix = prefix + key;

          config.alignWith.push(keyWithPrefix);
          config.prefixed.push(keyWithPrefix);
          originalConfigs[keyWithPrefix] = config;
        });
      }
    }
  }

  /**
   * Convert config in Atom format to usable config by aligner
   * @param {Object} schema
   * @return {Object} Converted config object
   */
  convertAtomConfig(schema) {
    let convertedConfig = {};

    for (let key in schema) {
      let value = schema[key];

      let keys = key.split('-');
      let property = keys.pop();

      // if there are no characters and it's a top level config
      if (!keys.length) {
        continue;
      }

      // iterate to the correct object depth
      let currentObject = convertedConfig;
      keys.forEach((configPathKey) => {
        currentObject[configPathKey] = currentObject[configPathKey] || {};
        currentObject = currentObject[configPathKey];
      });

      currentObject[property] = value.default != null ? value.default : value;
    }

    // Enable character alignment by default
    for (let character in convertedConfig) {
      let config = convertedConfig[character];
      if (config.enabled == null) {
        config.enabled = true;
      }
    }

    return convertedConfig;
  }

  /**
   * Convert Atom config object into supported format and update config
   * @param {Object} newConfig Config object in Atom format
   */
  updateConfigWithAtom(packageId, newConfig) {
    if (!packageId) return;
    this.updateSetting(packageId, this.convertAtomConfig(newConfig));
  }

  /**
   * @param {string} character
   * @param {String} languageScope
   * @return {object}
   */
  getConfig(character, editor) {
    let languageScope = editor.getCursorScope().getScopeChain();
    let languageScopeArr = languageScope.split(' ');

    for (let id in this.settings) {
      let config = this.settings[id];

      if (languageScope &&
          config.selector &&
          this._isSelectorInScope(config.selector, languageScopeArr) &&
          config[character] &&
          config[character].enabled) {
        return config[character];
      }
    }
  }

  _isSelectorInScope(selectors, languageScopeArr) {
    return selectors.some((selector) => {
      return languageScopeArr.indexOf(selector) != -1;
    });
  }

  /**
   * Check if the character can align with the original character. Usually used
   * for checking operator with prefixes
   * @param {string} character Original character
   * @param {string} toMatch Character to see if it can be align with original character
   * @param {object} config
   * @return {boolean}
   */
  canAlignWith(character, toMatch, config) {
    if (character == toMatch) return true;

    let alignWith = config.alignWith;

    return alignWith && alignWith.indexOf(toMatch) != -1;
  }

  /**
   * Check if the operator/character has prefix or not
   * @param {string} character
   * @param {Object} config
   * @return {boolean}
   */
  isPrefixed(character, config) {
    let prefixed = config ? config.prefixed : [];

    return prefixed && prefixed.indexOf(character) != -1;
  }
}

module.exports = new OperatorConfig();
