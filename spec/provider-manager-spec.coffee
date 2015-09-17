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
      providerManager.unregister 'aligner-coffee'

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

    providerManager.register provider

    expect(providerManager.providers['aligner-coffee']).toBeDefined()

    providerManager.unregister 'aligner-coffee'

    expect(providerManager.providers['aligner-coffee']).toBeUndefined()
