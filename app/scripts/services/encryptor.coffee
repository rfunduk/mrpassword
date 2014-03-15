class App.Services.Encryptor
  PARANOIA = 5
  constructor: ->
    sjcl.random.startCollectors()
    @_collectorInterval = setInterval( @checkReady, 25 )
  checkReady: =>
    if sjcl.random.isReady( @constructor.PARANOIA )
      # console.log "SJCL random number generator paranoia level satisfied..."
      sjcl.random.stopCollectors()
      clearInterval( @_collectorInterval )

  encrypt: sjcl.encrypt
  decrypt: sjcl.decrypt

App.sjcl = new App.Services.Encryptor
