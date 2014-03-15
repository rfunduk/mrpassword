class App.Views.Header extends Backbone.View
  events:
    'click .action-logout': 'logout'
    'click .action-create-password': 'createPassword'

  initialize: ->
    @listenTo App.dispatcher, 'updateHeader', @render

  render: ->
    @$el.replaceWith Handlebars.partials.header()

  createPassword: ->
    App.dispatcher.trigger 'createPassword'

  logout: ->
    App.router.navigate( 'logout', trigger: true )
