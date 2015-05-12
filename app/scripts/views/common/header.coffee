class App.Views.Header extends Backbone.View
  events:
    'click .action-logout': 'logout'
    'click .action-create-password': 'createPassword'

  loading: false

  initialize: ->
    @listenTo App.dispatcher, 'updateHeader', @render
    @listenTo App.dispatcher, 'saving', @startLoading
    @listenTo App.dispatcher, 'saved', @stopLoading

  startLoading: -> @$('h1 span.glyphicon').addClass 'spinning'
  stopLoading: -> @$('h1 span.glyphicon').removeClass 'spinning'

  render: ->
    @$el.replaceWith Handlebars.partials.header( loading: @loading )

  createPassword: ->
    App.dispatcher.trigger 'createPassword'

  logout: ->
    App.router.navigate( 'logout', trigger: true )
