App.Views.Passwords ?= {}

class App.Views.Passwords.TagsFilterer extends Backbone.View
  tagName: 'ul'
  events:
    'click li': 'updateFilters'

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

  render: ->
    tags = App.tags.toJSON( App.filteredTags.pluck('id') )
    @$el.html App.Templates.passwords.tags_filter( tags: tags )
    @
