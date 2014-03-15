describe 'Mr. Password', ->
  it 'should define App', ->
    expect( App ).to.be.an('object')

  describe 'App', ->
    it 'should have a dispatcher', ->
      expect( App.dispatcher ).to.not.be(undefined)

    it 'should act as a dispatcher', ( done ) ->
      App.dispatcher.on 'message', -> done()
      App.dispatcher.trigger 'message'
