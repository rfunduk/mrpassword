client = new Dropbox.Client key: '@@dropboxApiKey'

window.dropboxApi =
  client: client
  datastore: null
  data: null
  deferred: $.Deferred()
  ready: ( cb ) -> @deferred.done( cb )
  _actuallySave: _.throttle(
    ->
      @client.writeFile 'vault.json', JSON.stringify(@data, undefined, 2), ( error, stat ) ->
        if error
          alert("Uh oh, a problem saving something here... Try again?")
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
      client.readFile 'vault.json', ( error, data ) ->
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

