App.Views.Passwords ?= {}

class App.Views.Passwords.List extends Backbone.View
  initialize: ->
    @listenTo App.passwords, 'reset', @render
    @listenTo App.passwords, 'add', @renderItem
    @listenTo App.filteredTags, 'add remove reset filter', @filter
    @listenTo App.dispatcher, 'changeSearchTerm', @filter
    @subviews = {}

  remove: ->
    _.values @subviews, ( v ) -> v.remove?()
    @subviews = {}
    super()

  satisfiesSearchTerm: ( m ) ->
    return true if App.searchTerm.length == 0
    !!m.get('name').match( new RegExp( App.searchTerm, 'i' ) )

  filter: ->
    if _.isEmpty( @subviews )
      @render()
      return
    else
      @$('.empty-placeholder').remove()

    oneShown = false
    if App.filteredTags.isEmpty()
      # if we have NO filtered tags, show everything
      _.each @subviews, ( v, cid ) =>
        if @satisfiesSearchTerm(App.passwords.get(cid))
          oneShown = true
          v.$el.show()
        else
          v.$el.hide()
    else
      # we need to hide/show views depending on
      # the model having the chosen tags
      @$('.empty-placeholder').remove()
      filteredTags = App.filteredTags.pluck('id')
      _.each @subviews, ( view, modelCid ) =>
        password = App.passwords.get(modelCid)
        tags = password.get('tags')

        hasAllFilteredTags = _.every filteredTags, ( tagId ) ->
          _.include( tags, tagId )
        satisfiesSearchTerm = @satisfiesSearchTerm( password )

        if hasAllFilteredTags && satisfiesSearchTerm
          view.$el.show()
          oneShown = true
        else
          view.$el.hide()

    unless oneShown
      @$el.append( App.Templates.passwords.empty_placeholder( filtered: true ) )

  render: ->
    html = if App.passwords.isEmpty()
      App.Templates.passwords.empty_placeholder()
    else
      "<div class='list-group'></div>"
    @$el.html( html )
    App.passwords.each @renderItem, @
    @

  renderItem: ( item ) ->
    @$('.empty-placeholder').remove()
    v = new App.Views.Passwords.Row( model: item )
    v.show()
    @$('.list-group').prepend v.el
    @subviews[item.cid] = v
