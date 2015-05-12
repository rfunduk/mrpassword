class Router extends Backbone.Router
  _routes:
    'login': 'login'
    'logout': 'logout'
    'settings': 'settings'
    '': 'main'

  initialize: ->
    # setup routes by hand so they set their
    # name before being called
    # this also acts as a before_action to ensure the
    # user is logged in to access logout/settings/main
    @routes = {}
    _.each @_routes, ( fnName, routeKey ) =>
      fn = @[fnName]
      @routes[routeKey] = ( args... ) =>
        if fnName != 'login' && !window.dropboxApi.client.isAuthenticated()
          @navigate( 'login', trigger: true )
        else
          @_currentRoute = fnName
          fn.apply( @, args... )
    @_bindRoutes()

  onRoute: ( route ) -> @_currentRoute == route

  execute: ( cb, args ) ->
    # cleanup old header
    if @header
      loading = @header.loading
      @header.remove()
      @header = null

    # cleanup old view
    if @view
      @view.remove()
      @view = null

    cb.apply( @, args ) if cb

    @header = new App.Views.Header( el: $('header'), loading: !!loading )

  login: ->
    @view = new App.Views.Login
    $('.container').html @view.render().el
  logout: ->
    window.dropboxApi.client.signOut()
    @view = new App.Views.LoggedOut
    $('.container').html @view.render().el

  settings: ->
    @view = new App.Views.Settings
    $('.container').html @view.render().el

  main: ->
    if !App.settings.hasMasterPassword()
      @navigate( 'settings', trigger: true )
    else
      @view = new App.Views.Main
      $('.container').html @view.render().el


$(document).ready ->
  window.dropboxApi.ready ->
    App.passwords = new App.Passwords
    App.tags = new App.Tags

    if window.dropboxApi.client.isAuthenticated()
      App.passwords.fetch()
      App.tags.fetch()

    filtered = (window.localStorage.getItem( 'filteredTags' ) || "").split('|||')
    App.filteredTags = new App.Tags(
      App.tags.filter ( tag ) -> _.include( filtered, tag.get('id') )
    )
    App.filteredTags.on 'add remove reset', ->
      window.localStorage.setItem( 'filteredTags', App.filteredTags.pluck('id').join('|||') )

    App.router = new Router()
    Backbone.history.start()
    $('.container').removeClass('loading')

    # DATASTORE MIGRATION FEATURE
    if window.dropboxApi.client.isAuthenticated() && !window.localStorage.getItem( 'noMigrationPrompt' )
      $('.dropbox-fail').show().on 'click', 'button.migrate', ( e ) ->
        e.preventDefault()
        $('.dropbox-fail').hide()
        $('.container').empty().addClass('loading')
        migrator = new App.Services.Migrator
        migrator.run ( error, data ) ->
          $('.container').removeClass('loading')
          if error then alert( "Uh oh, that didn't work :( -- send me an email maybe?" )
          else
            App.passwords.fetch()
            App.tags.fetch()
            App.router.navigate( '/', trigger: true, replace: true )

    App.filteredTags.trigger('filter')
