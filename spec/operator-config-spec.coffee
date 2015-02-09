operatorConfig = require '../lib/operator-config'

describe 'Operator Config', ->
  describe 'getConfig', ->
    it 'should get the config from config.json', ->
      expect(operatorConfig.getConfig('=')).toBeDefined()

    it 'should return null when character is not supported', ->
      expect(operatorConfig.getConfig('-')).toBeUndefined()

    it 'should be able to get prefixed operator config', ->
      expect(operatorConfig.getConfig('+=')).toBeDefined()

  describe 'canAlignWith', ->
    it 'should return true if they are the same', ->
      expect(operatorConfig.canAlignWith('=', '=')).toBe true

    it 'should return true for supported prefixed operator', ->
      expect(operatorConfig.canAlignWith('=', '+=')).toBe true

    it 'should return false for unsupported prefixed operator', ->
      expect(operatorConfig.canAlignWith('=', '1=')).toBe false

  describe 'isPrefixed', ->
    it 'should return true when operator has prefix', ->
      expect(operatorConfig.isPrefixed('+=')).toBe true

    it 'should return false when operator does not have prefix', ->
      expect(operatorConfig.isPrefixed('=')).toBe false
