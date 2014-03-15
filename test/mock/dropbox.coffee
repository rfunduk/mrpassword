# emulates Dropbox.Datastore.List
class List
  constructor: ( @_array ) -> null
  toArray: -> @_array

# emulates Dropbox.Datastore.Record
class Record
  constructor: ( table, id, fields ) ->
    @_id = id
    @_table = table
    @update( fields )
  set: ( key, value ) ->
    fields = {}
    fields[key] = value
    @update fields
  getId: -> @_id
  getFields: -> @_data
  get: ( field ) -> @_data[field]
  deleteRecord: -> @_table.remove( @ )
  update: ( fields ) ->
    # emulate dropbox by wrapping arrays
    # in a List class which is later converted back
    # into an array by App.Password
    _.each fields, ( value, key ) ->
      fields[key] = new List( value ) if _.isArray(value)
    @_data = _.extend( {}, @_data, fields )

# emulates Dropbox.Datastore.Table
class Table
  constructor: ( name ) ->
    @_name = name
    @_data = {}
    @_nextId = 1
  get: ( key ) -> @_data[key]
  remove: ( id ) -> delete @_data[id]
  query: -> _.values( @_data )
  getOrInsert: ( id, value ) ->
    @get( id ) || @insert( value, id )
  insert: ( object, id=null ) ->
    id ?= @_nextId++
    @_data[id] = new Record( @, id, object )

# emulates Dropbox.Datastore
class Datastore
  constructor: -> @_tables = {}
  getTable: ( name ) -> @_tables[name] ?= new Table( name )

# emulates Dropbox.Datastore.DatastoreManager
class DatastoreManager
  constructor: ( @_datastores={} ) -> null
  openDefaultDatastore: ( cb ) =>
    @_datastores.default ?= new Datastore
    cb( null, @_datastores.default )
  deleteDatastore: ( name, cb ) =>
    delete @_datastores.default
    cb() if cb

# emulates Dropbox.Client
class Client
  constructor: -> @_manager = new DatastoreManager
  authenticate: -> null
  isAuthenticated: -> return true
  getDatastoreManager: -> @_manager


# global Dropbox namespace
# we only need to expose Client
window.Dropbox = Client: Client
