configs = require '../config'

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
    for key, config of configs
      if config.prefixes?
        config.alignWith = [key]
        config.prefixed = []

        for prefix in config.prefixes
          keyWithPrefix = prefix + key

          config.alignWith.push keyWithPrefix
          config.prefixed.push keyWithPrefix
          configs[keyWithPrefix] = config

  ###
  @function
  @name getConfig
  @param {string} character
  @returns {boolean}
  ###
  getConfig: (character) ->
    return configs[character]

  ###
  @function
  @name canAlignWith
  @description
  Check if the character can align with the original character. Usually used
  for checking operator with prefixes
  @param {string} character Original character
  @param {string} toMatch Character to see if it can be align with original character
  @returns {boolean}
  ###
  canAlignWith: (character, toMatch) ->
    if character is toMatch
      return true

    alignWith = @getConfig(character).alignWith

    return alignWith? && (toMatch in alignWith)

  ###
  @function
  @name isPrefixed
  @description
  Check if the operator/character has prefix or not
  @param {string} character
  @returns {boolean}
  ###
  isPrefixed: (character) ->
    prefixed = @getConfig(character)?.prefixed

    return prefixed? && (character in prefixed)

module.exports = new OperationConfig()
