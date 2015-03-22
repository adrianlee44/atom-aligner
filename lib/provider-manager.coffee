class ProviderManager
  constructor: ->
    @providers = []

  register: (provider) ->
    @providers.push provider

  unregister: (provider) ->
    index = @providers.indexOf provider
    @providers.splice index, 1

  getProviderIdByScope: (scope) ->
    for provider in @providers
      if provider.selector.indexOf(scope) != -1
        return provider.id

    return null

module.exports = new ProviderManager()
