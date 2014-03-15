client = new Dropbox.Client key: '@@dropboxApiKey'

client.authenticate(
  { interactive: false }
  ( error ) -> if error then alert("Sorry! Dropbox Datastore authentication failure: #{error}")
)

deferred = $.Deferred()

window.dropboxApi =
  client: client
  datastore: null
  ready: ( cb ) -> deferred.done( cb )

if client.isAuthenticated()
  manager = client.getDatastoreManager()
  manager.openDefaultDatastore ( error, datastore ) ->
    # console.log 'datastore id', datastore.getId()
    if error
      deferred.reject( error )
    else
      window.dropboxApi.datastore = datastore
      deferred.resolve( datastore )
else
  deferred.resolve()
