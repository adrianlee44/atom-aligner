providerManager = require '../lib/provider-manager'
operatorConfig = require '../lib/operator-config'

describe 'ProviderManager', ->
  provider =
    selector: ['.source.coffee']
    id:       'aligner-coffee'
    config:
      ':-alignment': 'left'

  describe 'registering a provider', ->
    disposable = null

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

  describe 'registering and deactivating', ->
    it 'should work fine', ->
      spyOn console, 'error'

      disposable = providerManager.register provider

      disposable.dispose()

      providerManager.register provider

      expect(console.error).not.toHaveBeenCalled()

    xit 'should work fine with the package', ->
      spyOn console, 'error'

      waitsForPromise ->
        atom.packages.activatePackage('aligner')

      runs ->
        atom.packages.deactivatePackage('aligner')

      waitsForPromise ->
        atom.packages.activatePackage('aligner')

      runs ->
        expect(console.error).not.toHaveBeenCalled()
