App.Views.Passwords ?= {}

class App.Views.Passwords.Create extends App.Views.Stepped
  steps: 3
  events:
    'keyup .master-password': 'checkMaster'
    'keyup h4[contenteditable]': 'setName'
    'click .action-generate': 'generate'
    'click .action-cancel': 'cancel'
    'click .action-save': 'save'
    'click .action-edit-tags': 'editTags'

  initialize: ->
    super()
    @generator = new App.Services.PasswordGenerator
    @listenTo App.dispatcher, 'createPassword', @showForm

  cancel: ->
    @$('.create-form').hide()
    @clearForm()
    @$('.action-create-password').show()

  showForm: ->
    @$('.action-create-password').hide()
    @$('.create-form').show()
    @reset()

  clearForm: ->
    @model = new App.Password tags: App.filteredTags.pluck('name')
    # @render()
    @$('.master-password, .new-password').val( null )
    @checkMaster()
    @$('h4').text('New Password')

  editTags: ->
    if @_tagsPopover
      @_tagsPopover.remove()
      @_tagsPopover = null
    else
      @_tagsPopover = new App.Views.Passwords.TagsEditor(
        el: @$('.action-edit-tags')
        model: @model
      )

  step1: ->
    @clearForm()
    if (h4 = @$('h4')).length > 0
      h4.trigger('focus')
      setTimeout(
        -> document.execCommand('selectAll',false,null)
        5
      )

  step2: ->
    if @_tagsPopover
      @_tagsPopover.remove()
      @_tagsPopover = null
    if App.master && App.settings.setting('rememberMaster')
      @revealPasswordField( App.master, 1 )
    else
      @$('.master-password').trigger( 'focus' )

  checkMaster: ->
    field = @$('.master-password')
    master = field.val()

    if App.settings.checkMaster( master )
      f = 'addClass'
      App.master = master if App.settings.setting('rememberMaster')
      @revealPasswordField( master )
    else
      f = 'removeClass'

    field.parents('.form-group')[f]('has-success')
    field.siblings('.glyphicon')[f]('glyphicon-ok')

  revealPasswordField: ( master, delay=1000 ) ->
    field = @$('.new-password')

    password = @model.password( master )
    field.val( password )

    setTimeout(
      =>
        @trigger('stepped.next')
        field.trigger('focus').get(0).select()
      delay
    )

  generate: ( e ) ->
    e.stopPropagation()
    e.preventDefault()
    field = @$('.new-password')
    field.val( @generator.generate( 30 ) )
    field.trigger('focus').get(0).select()

  setName: ->
    @model.set name: $.trim(@$('h4').text())

  save: ->
    @model.setPassword(
      App.master || @$('.master-password').val()
      @$('.new-password').val()
    )
    App.passwords.add @model
    @model.save()
    @cancel()

  remove: ->
    @$('[data-toggle=tooltip]').tooltip('destroy')
    @_tagsPopover?.remove()
    super()

  render: ->
    @$el.html App.Templates.passwords.create()
    @$('[data-toggle=tooltip]').tooltip()
    @
