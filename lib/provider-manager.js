/**
 * @fileoverview Manager for dealing with additional providers
 */

'use strict';

const operatorConfig = require('./operator-config');
const CompositeDisposable = require('atom').CompositeDisposable;

class ProviderManager {
  constructor() {}

  register(provider) {
    const disposable = new CompositeDisposable();
    const providerId = provider ? provider.id : '';

    if (providerId) {
      disposable.add(operatorConfig.add(providerId, provider));
      disposable.add(atom.config.observe(providerId, (value) => {
        return operatorConfig.updateConfigWithAtom(providerId, value);
      }));
    }

    // Unregister provider from providerManager
    return disposable
  }
}

module.exports = new ProviderManager();
