path = require 'path'
Q = require 'q'
SymbolsView = require './symbols-view'
TagReader = require './tag-reader'
{$$} = require 'atom-space-pen-views'

module.exports =
class GoToView extends SymbolsView
  toggle: ->
    if @panel.isVisible()
      @cancel()
    else
      @populate()

  viewForItem: ({position, name, file, directory, content}) ->
    if atom.project.getPaths().length > 1
      file = path.join(path.basename(directory), file)
    $$ ->
      @li class: 'three-lines', =>
        @div "#{name}:#{position.row + 1}", class: 'primary-line'
        @div directory, class: 'secondary-line'
        @div content, class: 'tertiary-line'

  detached: ->
    @deferredFind?.resolve([])

  findTag: (editor) ->
    @deferredFind?.resolve([])

    deferred = Q.defer()
    TagReader.find editor, (error, matches=[]) -> deferred.resolve(matches)
    @deferredFind = deferred
    @deferredFind.promise

  populate: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    @findTag(editor).then (matches) =>
      tags = []
      for match in matches
        match.position = @getTagLine(match)
        continue unless match.position
        match.name = path.basename(match.file)
        tags.push(match)

      if tags.length is 1
        @openTag(tags[0])
      else if tags.length > 0
        @setItems(tags)
        @attach()
