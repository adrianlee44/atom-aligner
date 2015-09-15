operatorConfig = require './operator-config'
{Disposable}   = require 'atom'

class ProviderManager
  constructor: ->
    @providers = {}
    @listeners = {}

  register: (provider) ->
    return false unless provider?.id?

    providerId = provider.id

    if @providers[providerId]?
      throw Error "Aligner: #{providerId} has already been activated"

    @providers[providerId] = provider

    operatorConfig.add providerId, provider

    @listeners[providerId] = atom.config.observe providerId, (value) ->
      operatorConfig.updateConfigWithAtom providerId, value

    # Unregister provider from providerManager
    return new Disposable => @unregister providerId

  unregister: (providerId) ->
    if providerId and @providers[providerId]
      delete @providers[providerId]

      operatorConfig.remove providerId

      if @listeners[providerId]?
        @listeners[providerId].dispose()
        delete @listeners[providerId]

module.exports = new ProviderManager()
