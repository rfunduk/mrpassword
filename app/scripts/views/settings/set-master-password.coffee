App.Views.Setting ?= {}

class App.Views.Setting.SetMasterPassword extends App.Views.Stepped
  steps: 3
  events:
    'keypress .new-master-password': 'confirmNewMaster'
    'keyup .confirm-master-password': 'checkConfirmedMaster'

  initialize: ->
    @checkConfirmedMaster = _.debounce( @rawCheckConfirmedMaster, 150 )
    super()

  step1: ->
    @_newMaster = null
    @$('.password-field').val( null )
    @$('.new-master-password').trigger('focus')

  step2: ->
    @_newMaster = @$('.new-master-password').val()
    if @_newMaster == null || @_newMaster.length == 0
      @prevStep()
    else
      @$('.confirm-master-password').trigger('focus')

  step3: ->
    App.settings.setMaster( @_newMaster )
    App.dispatcher.trigger('updateHeader')

  confirmNewMaster: ( e ) ->
    if e.which == 13
      e.preventDefault()
      e.stopPropagation()
      @nextStep()

  # constantly checks if the master password you are
  # typing is the same as the new master, and if so, moves on
  # (debounced)
  rawCheckConfirmedMaster: ->
    field = @$('.confirm-master-password')
    master = field.val()

    if master == @_newMaster
      f = 'addClass'
      setTimeout(
        => @trigger('stepped.next')
        800
      )
    else
      f = 'removeClass'

    field.parents('.form-group')[f]('has-success')
    field.siblings('.glyphicon')[f]('glyphicon-ok')


  render: ->
    @$el.html App.Templates.settings.set_master_password()
    @
