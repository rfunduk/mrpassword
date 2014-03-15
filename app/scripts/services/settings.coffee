class App.Services.Settings
  constructor: ( @api ) -> null

  hasMasterPassword: ->
    table = @api.datastore.getTable('settings')
    return !!table.get( 'master' )

  setMaster: ( password ) ->
    table = @api.datastore.getTable('settings')
    proof = App.sjcl.encrypt( password, 'MASTER' )
    record = table.getOrInsert 'master', data: proof
    record.set 'data', proof

  checkMaster: ( password ) ->
    try
      data = @api.datastore.getTable('settings').get('master').get('data')
      value = App.sjcl.decrypt( password, data )
      return value == 'MASTER'
    catch
      return false

  setting: ( key, value ) ->
    table = @api.datastore.getTable('settings')

    if value == undefined
      record = table.get key
      return null unless record
    else
      record = table.getOrInsert( key, value: value )
      record.set 'value', value
    record.get 'value'

App.settings = new App.Services.Settings( window.dropboxApi )
