operatorConfig = require './operator-config'

class ProviderManager
  constructor: ->
    @providers = {}
    @listeners = {}

  register: (provider) ->
    return false unless provider?.id?

    if @providers[provider.id]?
      throw Error "Aligner: Package has already been activated"

    @providers[provider.id] = provider

    operatorConfig.add provider.id, provider

    @listeners[provider.id] = atom.config.observe provider.id, (value) ->
      operatorConfig.updateConfigWithAtom provider.id, value

  unregister: (provider) ->
    id = provider?.id

    if id and @providers[id]
      @providers[id] = null

      operatorConfig.remove id

      if @listeners[id]?
        @listeners[id].dispose()
        @listeners[id] = null

module.exports = new ProviderManager()
