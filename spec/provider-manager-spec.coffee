providerManager = require '../lib/provider-manager'
operatorConfig = require '../lib/operator-config'

describe 'ProviderManager', ->
  describe 'registering a provider', ->
    disposable = null
    provider =
      selector: ['.source.coffee']
      id:       'aligner-coffee'
      config:
        ':-alignment': 'left'

    beforeEach ->
      spyOn(operatorConfig, 'add').andCallThrough()
      spyOn(atom.config, 'observe').andCallThrough()
      disposable = providerManager.register provider

    afterEach ->
      disposable.dispose()

    it 'should add provider to operator config', ->
      expect(operatorConfig.add).toHaveBeenCalled()

    it 'should add atom config listener', ->
      expect(atom.config.observe).toHaveBeenCalled()
