providerManager = require '../lib/provider-manager'

describe 'ProviderManager', ->
  it 'should initialize an empty list', ->
    expect(providerManager.providers).toEqual {}

  describe 'registering a provider', ->
    provider =
      selector: ['.source.coffee']
      id:       'aligner-coffee'
      config:
        ':-alignment': 'left'

    beforeEach ->
      providerManager.register provider

    afterEach ->
      providerManager.unregister provider

    it 'should register a provider', ->
      expect(providerManager.providers['aligner-coffee']).toBeDefined()

    it 'should be the same provider', ->
      expect(providerManager.providers['aligner-coffee']).toEqual provider

  it 'should unregistering a provider', ->
    provider =
      selector: ['.source.coffee']
      id:       'aligner-coffee'
      config:
        ':-alignment': 'left'

    afterEach ->
      providerManager.unregister provider

    providerManager.register provider

    expect(providerManager.providers['aligner-coffee']).toBeDefined()

    providerManager.unregister provider

    expect(providerManager.providers['aligner-coffee']).toBe null
