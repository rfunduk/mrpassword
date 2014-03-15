Backbone.sync = ( method, model, options ) ->
  api = window.dropboxApi
  # console.log method, model, options

  tableName = options.table || _.result(model, 'table')
  throw 'A "table" property or function must be specified' unless tableName

  table = api.datastore.getTable(tableName)

  switch method
    when 'create'
      fields = options.attrs || model.toJSON(options)
      record = table.insert fields
      model.set( id: record.getId() )
    when 'read'
      results = table.query( options.query )
      model.reset(
        _.map results, ( record ) ->
          obj = record.getFields()
          obj.id = record.getId()
          obj
        { parse: true }
      )
    when 'update'
      record = table.get( model.get('id') )
      record.update( _.omit( model.toJSON(), 'id' ) ) if record
    when 'delete'
      record = table.get( model.get('id') )
      record.deleteRecord() if record
