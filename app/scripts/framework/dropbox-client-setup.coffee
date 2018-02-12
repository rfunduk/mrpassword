client = new Dropbox clientId: '@@dropboxApiKey'
applicationHost = "#{window.location.protocol}//#{window.location.host}#{window.location.pathname}"

deleteVault = ->
  arg = { path: '/@@vaultFileName.json' }
  client.filesDelete( arg )

getVault = ( cb ) ->
  arg = { path: '/@@vaultFileName.json' }
  client.filesGetMetadata( arg ).then(
    ->
      client.filesDownload( arg ).then(
        ( data ) ->
          reader = new FileReader()
          reader.addEventListener 'loadend', ->
            cb( null, JSON.parse(reader.result) )
          reader.readAsText( data.fileBlob )
        ( error ) ->
          cb( error, null )
      )
    ( error ) ->
      if error && error.status == 409
        # file not found... 409 dropbox? really?
        # how about 404 instead
        cb( { status: 404 }, null )
      else
        swal(
          "What?",
          "Something really wrong happened...",
          'error'
        )
  )

saveVault = ( data, cb ) ->
  jsonData = JSON.stringify( data, undefined, 2 )
  arg = {
    contents: jsonData
    path: '/@@vaultFileName.json'
    mode: { '.tag': 'overwrite' }
    mute: true
  }
  client.filesUpload( arg ).then(
    ( stat, error ) ->
      swal(
        "Uh oh!",
        "There was a problem saving something here... Try again?",
        'error'
      ) if error
      cb( error, stat )
  )


window.dropboxApi =
  loggedIn: false
  data: null
  deferred: $.Deferred()
  nuke: deleteVault
  getVault: getVault
  authUrl: ->
    redirect = applicationHost
    client.getAuthenticationUrl( redirect )
  signOut: ->
    @loggedIn = false
    localStorage.removeItem('mrpassword-access-token')
  ready: ( cb ) -> @deferred.done( cb )
  save: ->
    App.dispatcher.trigger 'saving'
    @_actuallySave()
  _actuallySave: _.throttle(
    ->
      # first, read the vault and make sure the nonce
      # hasn't changed while we've been looking at/using the data
      getVault ( error, data ) =>
        if error || data.nonce != @data.nonce
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
          saveVault @data, ( error, stat ) ->
            App.dispatcher.trigger 'saved'
    1000
  )


parseHash = ( str ) ->
  return null if str.length == 0
  str.slice(1).split('&').reduce(
    ( params, param ) ->
      paramSplit = param.split('=').map (value) -> decodeURIComponent(value.replace('+', ' '))
      params[paramSplit[0]] = paramSplit[1]
      params
    {}
  )

parsedHash = parseHash( window.location.hash )
history.pushState( '', document.title, applicationHost )
if parsedHash && parsedHash.access_token
  localStorage.setItem(
    'mrpassword-access-token',
    parsedHash.access_token
  )

accessToken = localStorage.getItem('mrpassword-access-token')
if accessToken
  client.setAccessToken( accessToken )
  window.dropboxApi.loggedIn = true

if window.dropboxApi.loggedIn
  getVault ( error, data ) ->
    if error && error.status == 404
      data = { passwords: [], tags: [], settings: [], nonce: window.UUID() }
      saveVault data, ( error, stat ) ->
        window.dropboxApi.data = data
        App.dispatcher.trigger 'saved'
        window.dropboxApi.deferred.resolve data
    else if error
      swal(
        "Uh oh!",
        "Could not load password vault! Maybe back it up, and try again.",
        'error'
      )
    else
      window.dropboxApi.data = data
      window.dropboxApi.deferred.resolve data
else
  window.dropboxApi.deferred.resolve() # show intro page
