class App.Views.Footer extends Backbone.View
  events:
    'click .action-reload-now': 'reload'

  initialize: ->
    @listenTo App.dispatcher, 'saving', @startLoading
    @listenTo App.dispatcher, 'saved', @stopLoading

  startLoading: -> @$('.action-reload-now .glyphicon').addClass 'spinning'
  stopLoading: -> @$('.action-reload-now .glyphicon').removeClass 'spinning'

  reload: ( e ) ->
    e.preventDefault()
    App.dispatcher.trigger 'reloadData'
