class App.Views.LoggedOut extends Backbone.View
  className: 'logged-out'
  events:
    'click .action-login': 'login'
  login: ->
    window.dropboxApi.client.authenticate()
  render: ->
    @$el.html App.Templates.routes.logged_out()
    @
