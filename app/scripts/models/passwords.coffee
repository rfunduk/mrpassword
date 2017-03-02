class App.Password extends Backbone.Model
  table: -> _.result( @collection, 'table' )

  parse: ( attrs ) ->
    attrs

  password: ( master ) ->
    if @get('data')
      try
        App.sjcl.decrypt( master, @get('data') )
      catch e
        # console.log "ERROR:", e.toString()
        null

  setPassword: ( master, password ) ->
    @set data: App.sjcl.encrypt( master, password )

class App.Passwords extends Backbone.Collection
  model: App.Password
  table: 'passwords'

  @MAX_UPDATE_SPEED = 100

  comparator: ( p1, p2 ) ->
    n1 = p1.get('name')?.toLowerCase() || "ZZZZZZZZZZZ"
    n2 = p2.get('name')?.toLowerCase() || "ZZZZZZZZZZZ"
    return 0 if n1 == n2
    if n2 >= n1 then 1 else -1

  changeMasterPassword: ( currentMaster, newMaster, block ) ->
    fns = @map (password, i) ->
      ->
        # update to new password
        decrypted = password.password( currentMaster )
        password.setPassword newMaster, decrypted
        password.save()

        # calculate percentage through the update process
        total = App.passwords.length
        percentage = Math.round( ((i+1) / total) * 100 )

        # yield to interface to update progress bar
        block( false, percentage )

    # notify interface we're done
    fns.push -> block( true )

    interval = @constructor.MAX_UPDATE_SPEED
    runNextFn = ->
      fns.shift()()
      return if _.isEmpty(fns)
      setTimeout( runNextFn, interval )
    runNextFn()
