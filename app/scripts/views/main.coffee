class App.Views.Main extends Backbone.View
  className: 'main'

  remove: ->
    @passwordsList?.remove()
    @newPassword?.remove()
    @tagsFilterer?.remove()
    super()

  render: ->
    @$el.html App.Templates.routes.main()

    @newPassword = new App.Views.Passwords.Create( el: @$('#create-password') )
    @passwordsList = new App.Views.Passwords.List( el: @$('#passwords') )
    @tagsFilterer = new App.Views.Passwords.TagsFilterer( el: @$('#tags-filterer') )

    @newPassword.render()
    @tagsFilterer.render()
    @passwordsList.render()
    @
