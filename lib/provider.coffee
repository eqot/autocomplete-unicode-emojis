fs = require('fs')
path = require('path')
fuzzaldrin = require('fuzzaldrin')

module.exports =
  selector: '*'

  properties: {}
  keys: []

  loadProperties: ->
    fs.readFile path.resolve(__dirname, '..', 'properties.json'), (error, content) =>
      return if error

      @properties = JSON.parse(content)
      @keys = Object.keys(@properties)

  getSuggestions: ({prefix}) ->
    return unless prefix?.length

    words = fuzzaldrin.filter(@keys, prefix)
    for word in words
      {
        text: @properties[word].emoji
        rightLabel: word
      }
