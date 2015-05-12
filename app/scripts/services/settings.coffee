class App.Services.Settings
  constructor: ( @api ) -> null

  hasMasterPassword: ->
    return !!_.findWhere @api.data.settings, id: 'master'

  setMaster: ( password ) ->
    table = @api.data.settings
    proof = App.sjcl.encrypt( password, 'MASTER' )
    record = _.findWhere( @api.data.settings, id: 'master' )
    unless record
      record = { id: 'master', data: proof }
      @api.data.settings.push record
    record.data = proof
    @api.save()

  checkMaster: ( password ) ->
    try
      data = _.findWhere( @api.data.settings, id: 'master' ).data
      value = App.sjcl.decrypt( password, data )
      return value == 'MASTER'
    catch
      return false

  setting: ( key, value ) ->
    table = @api.data.settings

    if value == undefined
      record = _.findWhere( table, id: key )
      return null unless record
    else
      record = _.findWhere( table, id: key )
      if record
        record.value = value
      else
        record = { id: key, value: value }
        table.push record
      @api.save()
    record.value

App.settings = new App.Services.Settings( window.dropboxApi )
