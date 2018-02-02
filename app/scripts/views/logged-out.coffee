class App.Views.LoggedOut extends Backbone.View
  className: 'logged-out'
  render: ->
    authUrl = window.dropboxApi.authUrl()
    @$el.html App.Templates.routes.logged_out( { authUrl } )
    @
