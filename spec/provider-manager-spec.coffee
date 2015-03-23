providerManager = require '../lib/provider-manager'

describe 'ProviderManager', ->
  it 'should initialize an empty list', ->
    expect(providerManager.providers.length).toBe 0

  describe 'registering a provider', ->
    provider =
      selector: ['.source.coffee']
      id:       'aligner-coffee'
      config:
        ':-alignment': 'left'

    beforeEach ->
      providerManager.register provider

    afterEach ->
      providerManager.providers.length = 0

    it 'should register a provider', ->
      expect(providerManager.providers.length).toBe 1

    it 'should be the same provider', ->
      expect(providerManager.providers[0]).toEqual provider

    it 'should get the id', ->
      providerId = providerManager.getProviderIdByScope('.source.coffee')

      expect(providerId).toBe 'aligner-coffee'

  it ' should unregistering a provider', ->
    provider =
      selector: ['.source.coffee']
      id:       'aligner-coffee'
      config:
        ':-alignment': 'left'

    providerManager.register provider

    expect(providerManager.providers.length).toBe 1

    providerManager.unregister provider

    expect(providerManager.providers.length).toBe 0
