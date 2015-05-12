App.Views.Passwords ?= {}

class App.Views.Passwords.TagsEditor extends Backbone.View
  popupSelector: -> "ul.tags-editor##{@model.cid}"

  initialize: ->
    @$el.popover( html: true, content: @content() )
    @$el.popover( 'show' )
    $('body').on 'click', "#{@popupSelector()} li .label", @updateTags

  remove: ->
    @$el.popover( 'destroy' )
    $('body').off 'click', "#{@popupSelector()} li .label", @updateTags
    @undelegateEvents()

  updateTags: ( e ) =>
    clicked = $(e.target).parents('li')
    clicked.toggleClass('active')

    tagIds = $("#{@popupSelector()} li.active").map ( _, el ) -> $(el).data('id')

    @model.set tags: tagIds.toArray()
    @model.save() unless @model.isNew()

  content: ->
    tagIds = @model.get('tags') || []
    selectedTags = _.filter(
      App.tags.pluck('id')
      ( id ) -> _.include( tagIds, id )
    )
    tags = App.tags.toJSON( selectedTags )
    html = App.Templates.passwords.tags_editor( cid: @model.cid, tags: tags )
