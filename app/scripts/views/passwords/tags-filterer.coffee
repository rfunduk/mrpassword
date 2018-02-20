App.Views.Passwords ?= {}

class App.Views.Passwords.TagsFilterer extends Backbone.View
  events:
    'click li': 'updateFilters'
    'keyup #search': 'updateSearch'
    'click .action-clear-search': 'clearSearch'

  initialize: ->
    @listenTo App.tags, 'reset', @render
    @listenTo App.filteredTags, 'reset', @render

  clearSearch: ( e ) ->
    e.preventDefault()
    el = @$('#search')
    el.val( '' )
    @updateSearch( e )
    el.focus()

  updateSearch: ( e ) ->
    App.dispatcher.trigger 'changeSearchTerm', @$('#search').val()

  updateFilters: ( e ) ->
    tagEl = $(e.target).parents('li.tag')
    tagId = tagEl.data('tag-id')

    if (found = App.filteredTags.get( tagId ))
      tagEl.removeClass('active')
      App.filteredTags.remove( found )
    else
      if e.altKey
        tagEl.addClass('active')
        App.filteredTags.add( App.tags.get( tagId ) )
      else
        tagEl.siblings().removeClass('active')
        App.filteredTags.reset( [ App.tags.get( tagId ) ] )
    @render()
    $('#search').focus()

  render: ->
    tags = App.tags.toJSON( App.filteredTags.pluck('id') )

    ul = @$('ul')
    if ul.length == 0
      ul = $('<ul></ul>')
      @$el.prepend( ul )

    tagFilterHtml = App.Templates.passwords.tags_filter( tags: tags )
    ul.replaceWith tagFilterHtml

    if @$('#search').val() != App.searchTerm
      @$('#search').val( App.searchTerm )

    @
