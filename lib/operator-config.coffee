configs = require '../config'

class OperationConfig
  constructor: ->
    for key, config of configs
      if config.prefixes?
        for prefix in config.prefixes
          keyWithPrefix = prefix + key

          configs[keyWithPrefix] = config

  getConfig: (character) ->
    return configs[character]

module.exports = new OperationConfig()
