{BufferedProcess} = require 'atom'
path = require 'path'

matcher = /^([^\s]+)\s+(\d+)\s+([^\s]+)\s+(.*)$/

readLine = (line) ->
  m = matcher.exec(line)

  line: +m[2]
  file: path.basename(m[3])
  directory: path.dirname(m[3])

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

    lines = []
    command = 'global'
    args = ['-xd', symbol]
    stdout = (str) ->
      lines = lines.concat(
        str.split('\n').map((l) -> l.trim()).filter((l) -> l != '').map(readLine))
    stderr = (err) -> console.log(err)
    exit = ->
      callback(null, lines)

    new BufferedProcess({command, args, stdout, stderr, exit})
