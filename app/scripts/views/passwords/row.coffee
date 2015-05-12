App.Views.Passwords ?= {}

class App.Views.Passwords.Row extends App.Views.Stepped
  className: 'list-group-item'
  tagName: 'a'
  steps: 3
  events:
    'click': 'navOrCancel'
    'keyup .master-password': 'checkMaster'
    'keydown .revealed-password': 'watchForCopy'
    'keyup h4[contenteditable]': 'updateName'
    'click .revealed-password': 'focus'
    'click .action-done': 'clearAndReset'
    'click .action-save': 'updatePassword'
    'click .action-edit-tags': 'editTags'
    'click .action-delete': 'delete'
    'click .action-edit': 'edit'
    'click .action-show': 'show'
    'click .action-generate': 'generate'

  initialize: ->
    @generator = new App.Services.PasswordGenerator

    @checkMaster = _.debounce( @rawCheckMaster, 150 )

    super()

    @$el.attr href: 'javascript:void(0);'

  navOrCancel: ( e ) ->
    target = $(e.target)
    if target.is('input, button, a')
      e.preventDefault()
      e.stopPropagation()
      return

    if @currentStep != 0
      @reset()
    else
      @nextStep() if @mode == 'show'

  focus: ->
    @$('.revealed-password').trigger('focus').get(0).select()

  remove: ->
    @_tagsPopover?.remove()
    super()

  delete: ( e ) ->
    e.preventDefault()
    e.stopPropagation()

    if @$el.hasClass('confirm-delete')
      @model.destroy()
      @remove()
    else
      @$el.addClass('confirm-delete')
      @$('.action-delete').trigger( 'blur' )
      setTimeout(
        => @$el.removeClass('confirm-delete')
        4000
      )

  # update the name of the password
  updateName: ->
    @model.save name: $.trim(@$('h4').text())

  # encrypt and set new data
  updatePassword: ->
    @model.setPassword(
      App.master || @$('.master-password').val()
      @$('.new-password').val()
    )
    @model.save()
    @reset()

  step1: ->
    @$('.password-field').val( null )
    @checkMaster()

  # step2 is asking for the master password
  # so skip the step if we have it remembered
  step2: ->
    if App.master && App.settings.setting('rememberMaster')
      @revealPasswordField( App.master, 1 )
    else
      @$('.master-password').trigger( 'focus' )

  # step3 is the password reveal or update step,
  # so don't allow us to go
  # here unless the master step worked, and also
  # take this opportunity to clear the master field
  step3: ->
    field = switch @mode
      when 'show' then @$('.revealed-password')
      when 'edit' then @$('.new-password')

    field.attr( type: 'text' )

    allowed = App.master || @$('.master-password').parents('.form-group').hasClass('has-success')
    @prevStep() unless allowed

  # when someone ctrl/cmd+c's in the revealed password
  # box, switch it to a password field and transition back
  # to step1 after 1 second
  watchForCopy: ( e ) ->
    if e.which == 67 && (e.ctrlKey || e.metaKey)
      setTimeout(
        => @$('.revealed-password').attr( type: 'password' )
        150
      )
      setTimeout( @clearAndReset, 1000 )

  # clears a revealed password and goes back to step1
  clearAndReset: ( e ) =>
    if e
      e.preventDefault()
      e.stopPropagation()

    @trigger('stepped.reset')
    @$('.revealed-password').val( null )

  # generates a new password in edit mode
  generate: ( e ) ->
    e.stopPropagation()
    e.preventDefault()
    field = @$('.new-password')
    field.val( @generator.generate( 30 ) )
    field.trigger('focus').get(0).select()

  # reveal this model's password given a correct  master password
  revealPasswordField: ( master, delay=1000 ) ->
    field = switch @mode
      when 'show' then @$('.revealed-password')
      when 'edit' then @$('.new-password')

    password = @model.password( master )
    field.val( password )

    setTimeout(
      =>
        @trigger('stepped.next')
        field.trigger('focus').get(0).select()
      delay
    )

  # constantly checks if the master password you are
  # typing is correct, and if so, moves on to revealing
  # this model's password
  # (debounced)
  rawCheckMaster: ->
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

  editTags: ->
    if @_tagsPopover
      @_tagsPopover.remove()
      @_tagsPopover = null
    else
      @_tagsPopover = new App.Views.Passwords.TagsEditor(
        el: @$('.action-edit-tags')
        model: @model
      )

  edit: ( e ) ->
    if e
      e.stopPropagation()
      e.preventDefault()
    @mode = 'edit'
    @render()
    # @$('[data-toggle=tooltip]').tooltip()
  show: ( e ) ->
    @_tagsPopover?.remove()
    @_tagsPopover = null
    if e
      e.stopPropagation()
      e.preventDefault()
    @mode = 'show'
    @render()

  # render this model in the appropriate mode
  render: ->
    json = @model.toJSON()
    # lookup tags so we can set colors, etc
    json.tags = App.tags.toJSON( @model.get('tags') )
    @$el.html App.Templates.passwords[@mode]( json )
    @
