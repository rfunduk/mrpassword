describe 'App.Templates', ->
  it 'should have templates', ->
    expect( App.Templates ).to.be.an('object')
    expect( App.Templates ).to.have.keys( 'passwords', 'routes', 'settings' )

  it 'should execute a compiled template', ->
    fn = -> App.Templates.routes.login()
    expect( fn ).to.not.throwError()
    expect( fn() ).to.contain("Welcome to Mr. Password!")
