class App.Views.Login extends Backbone.View
  className: 'login'
  render: ->
    authUrl = window.dropboxApi.authUrl()
    @$el.html App.Templates.routes.login( { authUrl } )
    @
