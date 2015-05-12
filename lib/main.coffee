module.exports =
  config:
    useEditorGrammarAsCtagsLanguage:
      default: true
      type: 'boolean'

  activate: ->
    @stack = []

    @editorSubscription = atom.commands.add 'atom-text-editor',
      'gnu-global:go-to-declaration': => @createGoToView().toggle()
      'gnu-global:return-from-declaration': => @createGoBackView().toggle()

  deactivate: ->
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
