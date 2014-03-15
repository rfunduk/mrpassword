App.Views.Passwords ?= {}

class App.Views.Passwords.TagsFilterer extends Backbone.View
  tagName: 'ul'
  events:
    'click li': 'updateFilters'

  updateFilters: ( e ) ->
    tagEl = $(e.target).parents('li.tag')
    tagEl.addClass('active')
    tagId = tagEl.data('tag-id')
    if (found = App.filteredTags.get( tagId ))
      App.filteredTags.remove( found )
    else
      App.filteredTags.add( App.tags.get( tagId ) )
    @render()

  render: ->
    tags = App.tags.toJSON( App.filteredTags.pluck('name') )
    @$el.html App.Templates.passwords.tags_filter( tags: tags )
    @
