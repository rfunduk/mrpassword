describe 'App.Passwords', ->
  master = '123456'
  passwords = null

  beforeEach ->
    dropboxApi.client.remove('vault.json')
    passwords = new App.Passwords

  it 'should get passwords', ->
    fn = -> passwords.fetch()
    expect( fn ).to.not.throwError()

  it 'should add passwords', ->
    fn = ->
      p = new App.Password( name: 'pass1' )
      passwords.add( p )
      p.save()
    expect( fn ).to.not.throwError()
    expect( passwords ).to.have.length(1)

  it 'should set a new password', ->
    fn = ->
      p = new App.Password( name: 'pass1' )
      p.setPassword( master, 'pa5sw0rd' )
    expect( fn ).to.not.throwError()

  it 'should order passwords reverse case-insensitive by name', ->
    _.each [ 'z', 'Ab', 'b', 'aa', '123ac', '123Ab', '123b' ], ( name ) ->
      p = new App.Password( name: name )
      passwords.add( p )
      p.save()

    # TODO - should not be necessary?
    passwords.sort()

    expect( passwords.pluck('name') ).to.eql(
      [ 'z', 'b', 'Ab', 'aa', '123b', '123ac', '123Ab' ]
    )


  describe 'tags', ->
    password = null

    beforeEach ->
      password = new App.Password( name: 'pass1', tags: [ 'tag1', 'tag2' ] )
      passwords.add( password )
      password.save()

    it 'should set tags', ->
      expect( password.get('tags') ).to.eql( [ 'tag1', 'tag2' ] )

    it 'should serialize/deserialize tags', ->
      id = password.id
      passwords.fetch()
      p = passwords.get(id)
      expect( p.get('tags') ).to.eql( [ 'tag1', 'tag2' ] )


  describe 'decrypting', ->
    password = null

    beforeEach ->
      password = new App.Password( name: 'pass1' )
      password.setPassword( master, 'pa5sw0rd' )

    it 'should decrypt with the correct master password', ->
      expect( password.password(master) ).to.eql('pa5sw0rd')

    it 'should not decrypt with an incorrect master password', ->
      expect( password.password('nope') ).to.be(null)
