operatorConfig = require '../lib/operator-config'
config         = require '../config'
extend         = require 'extend'

describe 'Operator Config', ->
  describe 'getConfig', ->
    it 'should get the config from config.json', ->
      expect(operatorConfig.getConfig('=')).toBeDefined()

    it 'should return null when character is not supported', ->
      expect(operatorConfig.getConfig('-')).toBeUndefined()

    it 'should be able to get prefixed operator config', ->
      expect(operatorConfig.getConfig('+=')).toBeDefined()

  describe 'canAlignWith', ->
    characterConfig = null
    beforeEach ->
      characterConfig = operatorConfig.getConfig '='

    it 'should return true if they are the same', ->
      expect(operatorConfig.canAlignWith('=', '=', characterConfig)).toBe true

    it 'should return true for supported prefixed operator', ->
      expect(operatorConfig.canAlignWith('=', '+=', characterConfig)).toBe true

    it 'should return false for unsupported prefixed operator', ->
      expect(operatorConfig.canAlignWith('=', '1=', characterConfig)).toBe false

  describe 'isPrefixed', ->
    it 'should return true when operator has prefix', ->
      characterConfig = operatorConfig.getConfig '+='
      expect(operatorConfig.isPrefixed('+=', characterConfig)).toBe true

    it 'should return false when operator does not have prefix', ->
      characterConfig = operatorConfig.getConfig '='
      expect(operatorConfig.isPrefixed('=', characterConfig)).toBe false

  describe 'updateSetting', ->
    setting = null

    beforeEach ->
      setting = extend true, {}, config.setting

    afterEach ->
      # Reset operatorConfig
      operatorConfig.updateSetting()

    it 'should update prefixed settings properly', ->
      setting['='].alignment = 'right'

      operatorConfig.updateSetting setting
      expect(operatorConfig.setting['+='].alignment).toBe 'right'

  describe 'getAtomConfig', ->
    atomConfig = null

    beforeEach ->
      atomConfig = operatorConfig.getAtomConfig()

    it 'should create key-value pairs for Atom config', ->
      expect(atomConfig['=-alignment']).toBeDefined()

    it 'should not create key-value pairs for prefixed operators', ->
      expect(atomConfig['+=-alignment']).toBeUndefined()

    it 'should contain title', ->
      expect(atomConfig['=-alignment'].title).toBeDefined()

  describe 'updateConfigWithAtom', ->
    afterEach ->
      # Reset operatorConfig
      operatorConfig.updateSetting()

    it 'should update with Atom setting changes', ->
      setting = '=-alignment': 'right'

      operatorConfig.updateConfigWithAtom setting
      expect(operatorConfig.setting['+='].alignment).toBe 'right'
