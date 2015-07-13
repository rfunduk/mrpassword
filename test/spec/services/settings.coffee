describe 'App.Services.Settings', ->
  it 'should set a setting', ->
    expect( App.settings.setting('setting1', true) ).to.eql(true)
    expect( App.settings.setting('setting2', false) ).to.eql(false)
    expect( App.settings.setting('setting3', 'test') ).to.eql('test')
    expect( App.settings.setting('setting4', 5) ).to.eql(5)

  it 'should change a setting', ->
    App.settings.setting('a-number', 1)
    App.settings.setting('a-number', 2)
    expect( App.settings.setting('a-number') ).to.eql(2)

  it 'should return null for a missing setting', ->
    expect( App.settings.setting('missing') ).to.be(null)


  describe 'master password', ->
    master = '123456'

    describe 'with no master', ->
      it 'should fail a check for a master password setting', ->
        expect( App.settings.hasMasterPassword() ).to.not.be.ok()
        expect( App.settings.checkMaster( 'nope' ) ).to.not.be.ok()

      it 'should set a master password', ->
        App.settings.setMaster( master )
        expect( App.settings.hasMasterPassword() ).to.be.ok()


    describe 'with a master', ->
      beforeEach -> App.settings.setMaster( master )

      it 'should have a master password', ->
        expect( App.settings.hasMasterPassword() ).to.be.ok()

      it 'should verify a master password', ->
        expect( App.settings.checkMaster( master ) ).to.be.ok()

      it 'should set a new master password', ->
        newMaster = '654321'
        App.settings.setMaster( newMaster )
        expect( App.settings.checkMaster( master ) ).to.not.be.ok()
        expect( App.settings.checkMaster( newMaster ) ).to.be.ok()

    describe 'changing the master password', ->
      passwords = null

      beforeEach ->
        dropboxApi.client.remove('@@vaultFileName.json')
        App.Passwords.MAX_UPDATE_SPEED = 1
        App.passwords = new App.Passwords
        _.each [ 'pass1', 'pass2', 'pass3', 'pass4' ], ( name ) ->
          p = new App.Password( name: name )
          p.setPassword( master, name )
          App.passwords.add( p )
          p.save()
        expect( App.passwords ).to.have.length(4)

      it 'change all passwords', ( cb ) ->
        newMaster = '654321'
        App.passwords.changeMasterPassword master, newMaster, ( done, i ) ->
          return unless done
          App.passwords.each ( password ) ->
            expect( password.password( master ) ).to.eql(null)
            expect( password.password( newMaster ) ).to.eql( password.get('name') )
          cb()
