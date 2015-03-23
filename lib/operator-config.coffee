configs         = require '../config'
extend          = require 'extend'
providerManager = require './provider-manager'

###
Example for '='
"=": {
  "alignment":  "left",
  "leftSpace":  true,
  "rightSpace": true,
  "prefixes":   ["+", "-", "&", "|", "<", ">", "!", "~", "%", "/", "*", "."],
  "scope":      "operator|assignment"
}
`alignWith` and `prefixed` get added if `prefixes` key exist
alignWith {array} Array of other operators that should be aligned with
prefixed {array} Array of operators that have prefixes
###

class OperationConfig
  constructor: ->
    @updateSetting()
    @mapping = configs.mapping

  ###
  @function
  @name updateSetting
  @description
  Update aligner setting based on config.json format
  @param {Object|null} newConfig Config object based on config.json format
  Not passing in an object will update with default config
  ###
  updateSetting: (newConfig) ->
    @setting = extend true, {}, configs.setting, newConfig

    for key, config of @setting
      if config.prefixes?
        config.alignWith = [key]
        config.prefixed  = []

        for prefix in config.prefixes
          keyWithPrefix = prefix + key

          config.alignWith.push keyWithPrefix
          config.prefixed.push keyWithPrefix
          @setting[keyWithPrefix] = config

  ###
  @function
  @name convertAtomConfig
  @description
  Convert config in Atom format to usable config by aligner
  @param {Object} config
  ###
  convertAtomConfig: (config) ->
    convertedConfig = {}

    for key, value of config
      [character, property] = key.split '-'

      convertedConfig[character] ?= {}
      convertedConfig[character][property] = value

    return convertedConfig

  ###
  @function
  @name updateConfigWithAtom
  @description
  Convert Atom config object into supported format and update config
  @param {Object} newConfig Config object in Atom format
  ###
  updateConfigWithAtom: (newConfig) ->
    config = @convertAtomConfig(newConfig)
    @updateSetting config

  ###
  @function
  @name getAtomConfig
  @description
  Get config object for Atom used in package setting
  @returns {Object}
  ###
  getAtomConfig: ->
    output = {}

    for key, config of configs.setting
      for configKey, configValue of config
        atomConfigKey = "#{key}-#{configKey}"
        continue unless @mapping[configKey]?
        output[atomConfigKey] = extend true, {}, @mapping[configKey]
        output[atomConfigKey].default = configValue

        if output[atomConfigKey].title
          output[atomConfigKey].title += "'#{key}'"

    return output

  ###
  @function
  @name getConfig
  @param {string} character
  @param {String} scope
  @returns {boolean}
  ###
  getConfig: (character, scope = 'base') ->
    providerId = providerManager.getProviderIdByScope scope

    if providerId
      config = @convertAtomConfig(atom.config.get(providerId))
      return config[character]

    return @setting[character]

  ###
  @function
  @name canAlignWith
  @description
  Check if the character can align with the original character. Usually used
  for checking operator with prefixes
  @param {string} character Original character
  @param {string} toMatch Character to see if it can be align with original character
  @param {string} scope
  @returns {boolean}
  ###
  canAlignWith: (character, toMatch, scope = 'base') ->
    if character is toMatch
      return true

    alignWith = @getConfig(character, scope).alignWith

    return alignWith? && (toMatch in alignWith)

  ###
  @function
  @name isPrefixed
  @description
  Check if the operator/character has prefix or not
  @param {string} character
  @param {string} scope
  @returns {boolean}
  ###
  isPrefixed: (character, scope = 'base') ->
    prefixed = @getConfig(character, scope)?.prefixed

    return prefixed? && (character in prefixed)

module.exports = new OperationConfig()
