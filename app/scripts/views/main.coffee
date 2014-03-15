class App.Views.Main extends Backbone.View
  className: 'main'

  initialize: ->
    @newPassword = new App.Views.Passwords.Create
    @passwordsList = new App.Views.Passwords.List
    @tagsFilterer = new App.Views.Passwords.TagsFilterer

  remove: ->
    @passwordsList.remove()
    @newPassword.remove()
    @tagsFilterer.remove()
    super()

  render: ->
    @$el.html App.Templates.routes.main()
    @$('#create-password').html @newPassword.render().el
    @$('#tags-filterer').html @tagsFilterer.render().el
    @$('#passwords').html @passwordsList.render().el
    @
