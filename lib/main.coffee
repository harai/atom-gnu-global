module.exports =
  config:
    useEditorGrammarAsCtagsLanguage:
      default: true
      type: 'boolean'

  activate: ->
    @stack = []

    @workspaceSubscription = atom.commands.add 'atom-workspace',
      'gnu-global:toggle-project-symbols': => @createProjectView().toggle()

    @editorSubscription = atom.commands.add 'atom-text-editor',
      'gnu-global:toggle-file-symbols': => @createFileView().toggle()
      'gnu-global:go-to-declaration': => @createGoToView().toggle()
      'gnu-global:return-from-declaration': => @createGoBackView().toggle()

  deactivate: ->
    if @fileView?
      @fileView.destroy()
      @fileView = null

    if @projectView?
      @projectView.destroy()
      @projectView = null

    if @goToView?
      @goToView.destroy()
      @goToView = null

    if @goBackView?
      @goBackView.destroy()
      @goBackView = null

    if @workspaceSubscription?
      @workspaceSubscription.dispose()
      @workspaceSubscription = null

    if @editorSubscription?
      @editorSubscription.dispose()
      @editorSubscription = null

  createFileView: ->
    unless @fileView?
      FileView  = require './file-view'
      @fileView = new FileView(@stack)
    @fileView

  createProjectView: ->
    unless @projectView?
      ProjectView  = require './project-view'
      @projectView = new ProjectView(@stack)
    @projectView

  createGoToView: ->
    unless @goToView?
      GoToView = require './go-to-view'
      @goToView = new GoToView(@stack)
    @goToView

  createGoBackView: ->
    unless @goBackView?
      GoBackView = require './go-back-view'
      @goBackView = new GoBackView(@stack)
    @goBackView
