App.Views.Passwords ?= {}

class App.Views.Passwords.List extends Backbone.View
  className: 'list-group'
  tagName: 'div'

  initialize: ->
    @listenTo App.passwords, 'add', @renderItem
    @listenTo App.filteredTags, 'add remove reset filter', @filter
    @subviews = {}

  remove: ->
    _.values @subviews, ( v ) -> v.remove?()
    @subviews = {}
    super()

  filter: ->
    if App.filteredTags.isEmpty()
      # if we have NO filtered tags, show everything
      if _.isEmpty( @subviews )
        @render()
      else
        _.each @subviews, ( v ) -> v.$el.show()
        @$('.empty-placeholder').remove()
    else
      # we need to hide/show views depending on
      # the model having the chosen tags
      @$('.empty-placeholder').remove()
      filteredNames = App.filteredTags.pluck('name')
      oneShown = false
      _.each @subviews, ( view, modelCid ) ->
        password = App.passwords.get(modelCid)
        tags = password.get('tags')

        hasAllFilteredTags = _.every filteredNames, ( tagName ) ->
          _.include( tags, tagName )

        if hasAllFilteredTags
          view.$el.show()
          oneShown = true
        else
          view.$el.hide()

      unless oneShown
        @$el.append( App.Templates.passwords.empty_placeholder( filtered: true ) )

  render: ->
    if App.passwords.isEmpty()
      @$el.html( App.Templates.passwords.empty_placeholder() )
    App.passwords.each @renderItem, @
    @

  renderItem: ( item ) ->
    @$('.empty-placeholder').remove()
    v = new App.Views.Passwords.Row( model: item )
    v.show()
    @$el.prepend v.el
    @subviews[item.cid] = v
