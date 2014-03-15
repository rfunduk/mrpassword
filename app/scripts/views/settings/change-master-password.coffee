App.Views.Setting ?= {}

class App.Views.Setting.ChangeMasterPassword extends App.Views.Stepped
  steps: 5
  events:
    'keyup .current-master-password': 'checkCurrentMaster'
    'keypress .new-master-password': 'confirmNewMaster'
    'keyup .confirm-master-password': 'checkConfirmedMaster'

  initialize: ->
    @checkCurrentMaster = _.debounce( @rawCheckCurrentMaster, 150 )
    @checkConfirmedMaster = _.debounce( @rawCheckConfirmedMaster, 150 )
    super()

  render: ->
    @$el.html App.Templates.settings.change_master_password()
    @

  step1: -> @$('.password-field').val( null )
  step2: -> @$('.current-master-password').trigger('focus')
  step3: -> @$('.new-master-password').trigger('focus')

  step4: ->
    @_newMaster = @$('.new-master-password').val()
    if @_newMaster == null || @_newMaster.length == 0
      @prevStep()
    else
      @$('.confirm-master-password').trigger('focus')

  step5: ->
    # perform the actual change (!)
    newMaster = @_newMaster
    currentMaster = @_currentMaster

    progressBar = @$('.progress .progress-bar')

    App.settings.setMaster( newMaster )

    App.passwords.changeMasterPassword currentMaster, newMaster, ( done, percentage ) =>
      if done
        @reset()
      else
        progressBar.attr( 'aria-valuenow', percentage )
        progressBar.find('span').text( "#{percentage}% Complete" )
        progressBar.css( width: "#{percentage}%" )

  confirmNewMaster: ( e ) ->
    if e.which == 13
      e.preventDefault()
      e.stopPropagation()
      @nextStep()

  # constantly checks if the master password you are
  # typing is correct, and if so, moves on
  # (debounced)
  rawCheckCurrentMaster: ->
    field = @$('.current-master-password')
    master = field.val()

    if App.settings.checkMaster( master )
      f = 'addClass'
      @_currentMaster = master
      setTimeout(
        => @trigger('stepped.next')
        800
      )
    else
      f = 'removeClass'

    field.parents('.form-group')[f]('has-success')
    field.siblings('.glyphicon')[f]('glyphicon-ok')

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
