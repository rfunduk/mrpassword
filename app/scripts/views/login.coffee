class App.Views.Login extends Backbone.View
  className: 'login'
  events:
    'click .action-login': 'login'
  login: ->
    window.dropboxApi.client.authenticate()
  render: ->
    @$el.html App.Templates.routes.login()
    @
