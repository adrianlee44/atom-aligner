'use strict';

const operatorConfig = require('../lib/operator-config');
const config = require('../config');
const extend = require('extend');
const Disposable = require('atom').Disposable;

const cssProvider = {
  selector: ['.source.css', '.source.html', '.source.css.less'],
  id: 'aligner-css',
  config: {
    ':-prefixes': {
      type: 'array',
      default: [':']
    },
    ':-alignment': {
      title: 'Padding for :',
      description: 'Pad left or right of the character',
      type: 'string',
      default: 'right'
    },
    ':-leftSpace': {
      title: 'Left space for :',
      description: 'Add 1 whitespace to the left',
      type: 'boolean',
      default: false
    },
    ':-rightSpace': {
      title: 'Right space for :',
      description: 'Add 1 whitespace to the right',
      type: 'boolean',
      default: true
    },
    ':-scope': {
      title: 'Character scope',
      description: 'Scope string to match',
      type: 'string',
      default: 'key-value'
    }
  },
  privateConfig: {
    '|-alignment': 'right'
  }
};

describe('Operator Config', () => {
  beforeEach(() => {
    operatorConfig.removeAll();
    operatorConfig.add('aligner', config);
  });

  describe('getConfig', () => {
    it('should get the config from config.json', () => {
      expect(operatorConfig.getConfig('=')).toBeDefined();
    });

    it('should return null when character is not supported', () => {
      expect(operatorConfig.getConfig('-')).toBeUndefined();
    });

    it('should be able to get prefixed operator config', () => {
      expect(operatorConfig.getConfig('+=')).toBeDefined();
    });

    it('should get the right provider', () => {
      operatorConfig.add('aligner-css', cssProvider);
      expect(operatorConfig.getConfig(':', '.source.css')).toBeDefined();
    });

    it('should not be able to get any config', () => {
      expect(operatorConfig.getConfig('=>', '.source.ruby')).toBeUndefined();
    });
  });

  describe('add', () => {
    it('should add provider to settings', () => {
      let output = operatorConfig.add('aligner-css', cssProvider);
      let settings = operatorConfig.settings['aligner-css'];

      expect(settings).toBeDefined();
      expect(settings['|'].alignment).toBe('right');

      expect(settings.selector).toEqual(['.source.css', '.source.html', '.source.css.less']);
      expect(settings['::']).toBeDefined();
      expect(settings['::']).toEqual(settings[':']);
      expect(output instanceof Disposable).toBe(true);
      operatorConfig.remove('aligner-css');
    });

    it('should throw an error when initialized twice', () => {
      spyOn(console, 'error');
      operatorConfig.add('aligner-css', cssProvider);
      operatorConfig.add('aligner-css', cssProvider);

      expect(console.error).toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('should remove provider', () => {
      operatorConfig.add('aligner-css', cssProvider);
      expect(operatorConfig.settings['aligner-css']).toBeDefined();

      operatorConfig.remove('aligner-css');
      expect(operatorConfig.settings['aligner-css']).toBeUndefined();
    });
  });

  describe('canAlignWith', () => {
    let characterConfig = null;
    beforeEach(() => {
      characterConfig = operatorConfig.getConfig('=');
    });

    it('should return true if they are the same', () => {
      expect(operatorConfig.canAlignWith('=', '=', characterConfig)).toBe(true);
    });

    it('should return true for supported prefixed operator', () => {
      expect(operatorConfig.canAlignWith('=', '+=', characterConfig)).toBe(true);
    });

    it('should return false for unsupported prefixed operator', () => {
      expect(operatorConfig.canAlignWith('=', '1=', characterConfig)).toBe(false);
    });
  });

  describe('isPrefixed', () => {
    it('should return true when operator has prefix', () => {
      let characterConfig = operatorConfig.getConfig('+=');
      expect(operatorConfig.isPrefixed('+=', characterConfig)).toBe(true);
    });

    it('should return false when operator does not have prefix', () => {
      let characterConfig = operatorConfig.getConfig('=');
      expect(operatorConfig.isPrefixed('=', characterConfig)).toBe(false);
    });
  });

  describe('updateSetting', () => {
    it('should update prefixed settings properly', () => {
      let setting = {
        '=': {
          alignment: 'right'
        }
      };
      operatorConfig.updateSetting('aligner', setting);

      expect(operatorConfig.getConfig('+=').alignment).toBe('right');
    });
  });

  describe('initializePrefix', () => {
    it('should initialize prefix correctly', () => {
      let configs = {
        '=': {
          prefixes: ['+'],
          alignment: 'right'
        }
      };
      operatorConfig.initializePrefix(configs);

      expect(configs['+=']).toBeDefined();
      expect(configs['+=']).toBe(configs['=']);
      expect(configs['+='].alignWith).toEqual(['=', '+=']);
      expect(configs['='].prefixed).toEqual(['+=']);
    });
  });

  describe('getAtomConfig', () => {
    let atomConfig = null;
    beforeEach(() => {
      atomConfig = operatorConfig.getAtomConfig();
    });

    it('should create key-value pairs for Atom config', () => {
      expect(atomConfig['=-alignment']).toBeDefined();
    });

    it('should not create key-value pairs for prefixed operators', () => {
      expect(atomConfig['+=-alignment']).toBeUndefined();
    });

    it('should contain title', () => {
      expect(atomConfig['=-alignment'].title).toBeDefined();
    });
  });

  describe('updateConfigWithAtom', () => {
    it('should update with Atom setting changes', () => {
      let setting = {
        '=-alignment': 'right'
      };
      operatorConfig.updateConfigWithAtom('aligner', setting);

      expect(operatorConfig.getConfig('+=').alignment).toBe('right');
    });
  });

  describe('convertAtomConfig', () => {
    it('should convert 1 level object path correctly', () => {
      let output = operatorConfig.convertAtomConfig({
        ':-assignment': 'right'
      });

      expect(output[':'].assignment).toBe('right');
    });

    it('should convert nested object path correctly', () => {
      let output = operatorConfig.convertAtomConfig({
        ':-multiple-string-assignment': 'right'
      });

      expect(output[':'].multiple.string.assignment).toBe('right');
    });

    it('should include enabled option and default to true', () => {
      let output = operatorConfig.convertAtomConfig({
        ':-assignment': 'right'
      });

      expect(output[':'].enabled).toBe(true);
    });

    it('should include enabled option', () => {
      let output = operatorConfig.convertAtomConfig({
        ':-assignment': 'right',
        ':-enabled': false
      });

      expect(output[':'].enabled).toBe(false);
    });
  });
});
