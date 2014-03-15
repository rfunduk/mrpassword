App.Views.Setting ?= {}

class App.Views.Setting.Backup extends App.Views.Stepped
  steps: 4
  events:
    'keyup .current-master-password': 'checkCurrentMaster'
    'click .action-download-prepared': 'download'

  initialize: ->
    @checkCurrentMaster = _.debounce( @rawCheckCurrentMaster, 150 )
    super()

  step1: ->
    @$('.current-master-password').val( null )
    @checkCurrentMaster()

  step2: ->
    if @$('.backup-encryption').is(':checked')
      @$('.current-master-password').trigger('focus')
    else
      @nextStep()

  step3: ->
    @backupData()
    setTimeout(
      => @nextStep()
      350
    )

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
        => @backupData()
        800
      )
    else
      f = 'removeClass'

    field.parents('.form-group')[f]('has-success')
    field.siblings('.glyphicon')[f]('glyphicon-ok')

  backupData: ->
    decrypt = @$('.backup-encryption').is(':checked')
    master = @_currentMaster
    output = App.passwords.map ( password ) ->
      json = password.toJSON()
      json.password = password.password(master) if decrypt
      json
    @_blob = new Blob [JSON.stringify(output, undefined, 2)]

  download: ->
    now = new Date()
    # crazy javascript
    month = if (month = now.getMonth() + 1) < 10 then "0#{month}" else "#{month}"
    dateString = "#{now.getFullYear()}-#{month}-#{now.getDate()}"
    saveAs( @_blob, "mrpassword-#{dateString}.json" )
    delete @_blob
    @reset()

  render: ->
    @$el.html App.Templates.settings.backup()
    @
