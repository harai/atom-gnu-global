path = require 'path'
{Point} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'
fs = require 'fs-plus'

module.exports =
class SymbolsView extends SelectListView
  @activate: ->
    new SymbolsView

  initialize: (@stack) ->
    super
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @addClass('gnu-global')

  destroy: ->
    @cancel()
    @panel.destroy()

  getFilterKey: -> 'name'

  viewForItem: ({position, name, file, directory}) ->
    if atom.project.getPaths().length > 1
      file = path.join(path.basename(directory), file)
    $$ ->
      @li class: 'two-lines', =>
        if position?
          @div "#{name}:#{position.row + 1}", class: 'primary-line'
        else
          @div name, class: 'primary-line'
        @div file, class: 'secondary-line'

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No symbols found'
    else
      super

  cancelled: ->
    @panel.hide()

  confirmed: (tag) ->
    if tag.file and not fs.isFileSync(path.join(tag.directory, tag.file))
      @setError('Selected file does not exist')
      setTimeout((=> @setError()), 2000)
    else
      @cancel()
      @openTag(tag)

  openTag: (tag) ->
    if editor = atom.workspace.getActiveTextEditor()
      previous =
        position: editor.getCursorBufferPosition()
        file: editor.getURI()

    {position} = tag
    position = @getTagLine(tag) unless position
    if tag.file
      atom.workspace.open(path.join(tag.directory, tag.file)).done =>
        @moveToPosition(position) if position
    else if position
      @moveToPosition(position)

    @stack.push(previous)

  moveToPosition: (position, beginningOfLine=true) ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.scrollToBufferPosition(position, center: true)
      editor.setCursorBufferPosition(position)
      editor.moveToFirstCharacterOfLine() if beginningOfLine

  attach: ->
    @storeFocusedElement()
    @panel.show()
    @focusFilterEditor()

  getTagLine: (tag) -> new Point(tag.line - 1, 0)
