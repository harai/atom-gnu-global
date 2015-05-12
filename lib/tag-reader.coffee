{BufferedProces} = require 'atom'

module.exports =
  find: (editor, callback) ->
    if editor.getLastCursor().getScopeDescriptor().getScopesArray().indexOf('source.ruby') isnt -1
      # Include ! and ? in word regular expression for ruby files
      range = editor.getLastCursor().getCurrentWordBufferRange(wordRegex: /[\w!?]*/g)
    else
      range = editor.getLastCursor().getCurrentWordBufferRange()

    symbol = editor.getTextInRange(range)

    unless symbol?.length > 0
      return process.nextTick -> callback(null, [])

    # TODO: implement
    console.log('foobar')
