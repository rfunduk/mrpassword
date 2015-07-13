client = new Dropbox.Client key: '@@dropboxApiKey'

window.dropboxApi =
  client: client
  datastore: null
  data: null
  deferred: $.Deferred()
  ready: ( cb ) -> @deferred.done( cb )
  _actuallySave: _.throttle(
    ->
      jsonData = JSON.stringify( @data, undefined, 2 )
      @client.writeFile '@@vaultFileName.json', jsonData, ( error, stat ) ->
        alert("Uh oh, a problem saving something here... Try again?") if error
        App.dispatcher.trigger 'saved'
    1000
  )
  save: ->
    App.dispatcher.trigger 'saving'
    @_actuallySave()

client.authenticate(
  { interactive: false }
  ( error, client ) ->
    if error
      alert("Sorry! Dropbox authentication failure: #{error}")
      return
    else if client.isAuthenticated()
      client.readFile '@@vaultFileName.json', ( error, data ) ->
        if error
          data = { passwords: [], tags: [], settings: [] }
          window.dropboxApi.data = data
          window.dropboxApi.save()
        else
          window.dropboxApi.data = JSON.parse( data )
        window.dropboxApi.deferred.resolve data
    else
      window.dropboxApi.deferred.resolve() # show intro page
)
