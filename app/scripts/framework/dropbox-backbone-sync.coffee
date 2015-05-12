Backbone.sync = ( method, model, options ) ->
  data = window.dropboxApi.data
  # console.log method, model, options

  tableName = options.table || _.result(model, 'table')
  throw 'A "table" property or function must be specified' unless tableName

  table = data[tableName]

  switch method
    when 'create'
      newId = window.UUID() until newId && !_.findWhere(table, id: newId)
      fields = _.extend model.toJSON(options), options.attrs, id: newId
      table.push fields
      model.set( id: fields.id )
      window.dropboxApi.save()
    when 'read'
      results = _.where( table, options.query )
      model.reset( results )
    when 'update'
      record = _.findWhere( table, id: model.get('id') )
      if record && model.hasChanged()
        _.extend( record, _.omit( model.toJSON(), 'id' ), options.attrs )
        window.dropboxApi.save()
        model.trigger 'change'
    when 'delete'
      data[tableName] = _.reject( table, ( r ) -> r.id == model.get('id') )
      window.dropboxApi.save()
