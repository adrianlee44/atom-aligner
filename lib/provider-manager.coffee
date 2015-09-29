operatorConfig = require './operator-config'
{CompositeDisposable} = require 'atom'

class ProviderManager
  register: (provider) ->
    disposable = new CompositeDisposable
    providerId = provider?.id

    if providerId
      disposable.add operatorConfig.add providerId, provider

      disposable.add atom.config.observe providerId, (value) ->
        operatorConfig.updateConfigWithAtom providerId, value

    # Unregister provider from providerManager
    return disposable

module.exports = new ProviderManager()
