configs = require '../config'
extend  = require 'extend'
{Disposable} = require 'atom'

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
    @settings = {}

  ###
  @function
  @name add
  @description
  Add/register provider config
  @param {string} id Provider id
  @param {Object} provider Provider object
  ###
  add: (id, provider) ->
    if @settings[id]?
      console.error("#{id} has already been activated")

    else
      allConfigs    = extend {}, provider.config, provider.privateConfig
      @settings[id] = @convertAtomConfig allConfigs

      @settings[id].selector = provider.selector?.slice 0

      @initializePrefix @settings[id]

    new Disposable(@remove.bind(this, id))

  remove: (id) ->
    if @settings[id]?
      delete @settings[id]

  removeAll: ->
    @settings = {}

  ###
  @function
  @name updateSetting
  @description
  Update aligner setting based on config.json format
  @param {string} packageId
  @param {object} newConfig
  ###
  updateSetting: (packageId = 'aligner', newConfig) ->
    if @settings[packageId]
      extend true, @settings[packageId], newConfig

  initializePrefix: (originalConfigs) ->
    for key, config of originalConfigs
      if key isnt 'selector' and config.prefixes?
        config.alignWith = [key]
        config.prefixed  = []

        for prefix in config.prefixes
          keyWithPrefix = prefix + key

          config.alignWith.push keyWithPrefix
          config.prefixed.push keyWithPrefix
          originalConfigs[keyWithPrefix] = config

  ###
  @function
  @name convertAtomConfig
  @description
  Convert config in Atom format to usable config by aligner
  @param {Object} schema
  @returns {Object} Converted config object
  ###
  convertAtomConfig: (schema) ->
    convertedConfig = {}

    for key, value of schema
      [configPath... , property] = key.split '-'

      # iternate to the correct object depth
      currentObject = convertedConfig
      for configPathKey in configPath
        currentObject[configPathKey] ?= {}
        currentObject = currentObject[configPathKey]

      currentObject[property] =
        if value.default? then value.default else value

    # Enable character alignment by default
    for character, config of convertedConfig
      config.enabled ?= true

    return convertedConfig

  ###
  @function
  @name updateConfigWithAtom
  @description
  Convert Atom config object into supported format and update config
  @param {Object} newConfig Config object in Atom format
  ###
  updateConfigWithAtom: (packageId = 'aligner', newConfig) ->
    @updateSetting packageId, @convertAtomConfig(newConfig)

  ###
  @function
  @name getAtomConfig
  @description
  Get config object for Atom used in package setting
  @returns {Object}
  ###
  getAtomConfig: ->
    return configs.config

  ###
  @function
  @name getConfig
  @param {string} character
  @param {String} languageScope
  @returns {object}
  ###
  getConfig: (character, languageScope = 'base') ->
    for id, config of @settings
      if config.selector? and config.selector.indexOf(languageScope) isnt -1
        return config[character] if config[character]?.enabled

    # default settings for `character`
    return @settings.aligner[character]

  ###
  @function
  @name canAlignWith
  @description
  Check if the character can align with the original character. Usually used
  for checking operator with prefixes
  @param {string} character Original character
  @param {string} toMatch Character to see if it can be align with original character
  @param {object} config
  @returns {boolean}
  ###
  canAlignWith: (character, toMatch, config) ->
    if character is toMatch
      return true

    alignWith = config.alignWith

    return alignWith? && (toMatch in alignWith)

  ###
  @function
  @name isPrefixed
  @description
  Check if the operator/character has prefix or not
  @param {string} character
  @param {Object} config
  @returns {boolean}
  ###
  isPrefixed: (character, config) ->
    prefixed = config?.prefixed

    return prefixed? && (character in prefixed)

module.exports = new OperationConfig()
