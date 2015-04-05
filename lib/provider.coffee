fs = require('fs')
path = require('path')
fuzzaldrin = require('fuzzaldrin')

module.exports =
  selector: '*'

  wordRegex: /[\w\d_\+-]+$/
  properties: {}
  keys: []

  loadProperties: ->
    fs.readFile path.resolve(__dirname, '..', 'properties.json'), (error, content) =>
      return if error

      @properties = JSON.parse(content)
      @keys = Object.keys(@properties)

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return unless prefix?.length

    words = fuzzaldrin.filter(@keys, prefix)
    for word in words
      {
        text: @properties[word].emoji
        replacementPrefix: prefix
        rightLabel: word
      }

  getPrefix: (editor, bufferPosition) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    line.match(@wordRegex)?[0] or ''
