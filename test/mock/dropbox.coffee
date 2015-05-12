# emulates Dropbox.Client
class Client
  constructor: -> @_data = { passwords: [], tags: [], settings: [] }
  authenticate: ( opts, cb ) ->
    cb = opts if typeof(opts) == 'function'
    cb( null, this )
  isAuthenticated: -> return true
  writeFile: ( name, data, cb ) -> @_data = JSON.parse(data); cb( null, {} )
  readFile: ( name, cb ) -> cb( null, JSON.stringify(@_data) )
  remove: ( name ) -> @_data = { passwords: [], tags: [], settings: [] }

# global Dropbox namespace
# we only need to expose Client
window.Dropbox = Client: Client
