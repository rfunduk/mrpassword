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
        if fnName != 'login' && !window.dropboxApi.loggedIn
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
    if @footer
      @footer.remove()
      @footer = null

    # cleanup old view
    if @view
      @view.remove()
      @view = null

    cb.apply( @, args ) if cb

    @header = new App.Views.Header( el: $('header'), loading: !!loading )
    @footer = new App.Views.Footer( el: $('footer') )

  login: ->
    @view = new App.Views.Login
    $('.container').html @view.render().el
  logout: ->
    window.dropboxApi.signOut()
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

    if window.dropboxApi.loggedIn
      App.passwords.fetch()
      App.tags.fetch()

    saving = false
    App.dispatcher.on 'saving', -> saving = true
    App.dispatcher.on 'saved', -> saving = false
    App.dispatcher.on 'reloadData', ->
      return if saving
      App.dispatcher.trigger 'saving'
      window.dropboxApi.getVault ( error, data ) ->
        if !error
          window.dropboxApi.data = data
          App.passwords.fetch()
          App.tags.fetch()
          App.filteredTags.trigger('filter')
        App.dispatcher.trigger 'saved'

    document.addEventListener 'visibilitychange', ->
      App.dispatcher.trigger 'reloadData'

    App.searchTerm = window.localStorage.getItem( 'searchTerm' ) || ''
    App.dispatcher.on 'changeSearchTerm', ( term ) ->
      App.searchTerm = term
      window.localStorage.setItem( 'searchTerm', term )

    filtered = (window.localStorage.getItem( 'filteredTags' ) || "").split('|||')
    App.filteredTags = new App.Tags(
      App.tags.filter ( tag ) -> _.include( filtered, tag.get('id') )
    )
    App.filteredTags.on 'add remove reset', ->
      window.localStorage.setItem( 'filteredTags', App.filteredTags.pluck('id').join('|||') )

    App.router = new Router()
    Backbone.history.start()
    $('.container').removeClass('loading')

    App.filteredTags.trigger('filter')

    $('#search').focus()
    canAutoUpdate = true
