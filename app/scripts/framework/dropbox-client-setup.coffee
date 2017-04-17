client = new Dropbox.Client key: '@@dropboxApiKey'

window.dropboxApi =
  client: client
  datastore: null
  data: null
  deferred: $.Deferred()
  ready: ( cb ) -> @deferred.done( cb )
  _actuallySave: _.throttle(
    ->
      # first, read the vault and make sure the nonce
      # hasn't changed while we've been looking at/using the data
      @client.readFile '@@vaultFileName.json', ( error, data ) =>
        if error || JSON.parse( data ).nonce != @data.nonce
          swal(
            "Uh oh!",
            "Someone edited the vault out from under you! Please refresh and try again.",
            'error'
          )
          App.dispatcher.trigger 'saved'
        else
          # the nonce matches, so generate a new one
          # and store it so anyone elses wont match if they save
          @data.nonce = window.UUID()
          jsonData = JSON.stringify( @data, undefined, 2 )
          @client.writeFile '@@vaultFileName.json', jsonData, ( error, stat ) ->
            swal(
              "Uh oh!",
              "There was a problem saving something here... Try again?",
              'error'
            ) if error
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
      swal(
        "Sorry!",
        "Dropbox authentication failure: #{error}",
        'error'
      )
      return
    else if client.isAuthenticated()
      # console.log('LOADING VAULT', '@@vaultFileName.json')
      client.readFile '@@vaultFileName.json', ( error, data ) ->
        if error && error.status == 404
          data = { passwords: [], tags: [], settings: [] }
          window.dropboxApi.data = data
          window.dropboxApi.save()
        else if error
          swal(
            "Uh oh!",
            "Could not load password vault! Maybe back it up, and try again.",
            'error'
          )
        else
          window.dropboxApi.data = JSON.parse( data )
        window.dropboxApi.deferred.resolve data
    else
      window.dropboxApi.deferred.resolve() # show intro page
)
