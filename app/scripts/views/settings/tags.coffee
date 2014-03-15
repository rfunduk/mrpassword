App.Views.Setting ?= {}

class App.Views.Setting.Tags extends Backbone.View
  events:
    'change select': 'tagsChanged'

  remove: ->
    # first clean up _dirtyHack
    @_tagsInput.siblings('.bootstrap-tagsinput').off()

    @_tagsInput.tagsinput('destroy')
    super()

  tagsChanged: ->
    newTags = @_tagsInput.val()
    console.log 'tags changed', newTags
    App.tags.update( newTags )
    @setTagColors()

  setTagColors: ->
    @$('.bootstrap-tagsinput .tag').each ( i ) ->
      $(this).css backgroundColor: App.Tags.COLORS_BY_POSITION[i]

  # _dirtyHack: ( tagsInput ) ->
  #   # HACK
  #   # this is a dirty hack to make the tag input field
  #   # appear and disappear on focus (so it doesn't do things like
  #   # take up an extra line due to wrapping)
  #   (container = tagsInput.siblings('.bootstrap-tagsinput')).on( 'click', ->
  #     $(this).addClass('editing').find('input').trigger('focus')
  #   ).find('input').on( 'blur', ->
  #     setTimeout(
  #       =>
  #         input = container.find('input')
  #         if input.is(':last-child')
  #           newTag = input.val()
  #           if newTag.length > 0
  #             tagsInput.tagsinput( 'add', newTag )
  #             input.val('')
  #           container.removeClass('editing')
  #       100
  #     )
  #   )

  render: ->
    @$el.html App.Templates.settings.tags(
      tags: App.tags.pluck('name')
    )

    @_tagsInput = @$('[data-role=tagsinput]')
    @_tagsInput.tagsinput(
      tagClass: -> 'label label-primary'
      confirmKeys: [13, 9]
    )
    # @_dirtyHack( @_tagsInput )

    @setTagColors()

    @
