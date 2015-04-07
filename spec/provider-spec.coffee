packagesToTest =
  gfm:
    name: 'language-gfm'
    file: 'test.md'
  HTML:
    name: 'language-html'
    file: 'test.html'
  text:
    name: 'language-text'
    file: 'test.txt'

describe "Unicode emojis autocompletions", ->
  [editor, provider] = []

  getCompletions = ->
    cursor = editor.getLastCursor()
    start = cursor.getBeginningOfCurrentWordBufferPosition()
    end = cursor.getBufferPosition()
    prefix = editor.getTextInRange([start, end])
    request =
      editor: editor
      bufferPosition: end
      scopeDescriptor: cursor.getScopeDescriptor()
      prefix: prefix
    provider.getSuggestions(request)

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('autocomplete-unicode-emojis')

    runs ->
      provider = atom.packages.getActivePackage('autocomplete-unicode-emojis').mainModule.getProvider()

    waitsFor -> Object.keys(provider.properties).length > 0

  Object.keys(packagesToTest).forEach (packageLabel) ->
    describe "#{packageLabel} files", ->
      beforeEach ->
        waitsForPromise -> atom.packages.activatePackage(packagesToTest[packageLabel].name)
        waitsForPromise -> atom.workspace.open(packagesToTest[packageLabel].file)
        runs -> editor = atom.workspace.getActiveTextEditor()

      it "returns no completions without a prefix", ->
        editor.setText('')
        expect(getCompletions().length).toBe 0

      it "returns no completions with an improper prefix", ->
        editor.setText(':')
        editor.setCursorBufferPosition([0, 0])
        expect(getCompletions().length).toBe 0
        editor.setCursorBufferPosition([0, 1])
        expect(getCompletions().length).toBe 0

        editor.setText(':*')
        editor.setCursorBufferPosition([0, 1])
        expect(getCompletions().length).toBe 0

      it "autocompletes unicode emojis with a proper prefix", ->
        editor.setText """
          :sm
        """
        editor.setCursorBufferPosition([0, 3])
        completions = getCompletions()
        expect(completions.length).toBe 49
        expect(completions[0].text).toBe '😄'
        expect(completions[0].replacementPrefix).toBe ':sm'
        expect(completions[1].text).toBe '😏'

        editor.setText """
          :+
        """
        editor.setCursorBufferPosition([0, 2])
        completions = getCompletions()
        expect(completions.length).toBe 1
        expect(completions[0].text).toBe '👍'
        expect(completions[0].replacementPrefix).toBe ':+'
