describe 'App.Services.PasswordGenerator', ->
  generator = new App.Services.PasswordGenerator

  it 'should generate a password', ->
    password = generator.generate(30)
    expect( password ).to.have.length(30)
    expect( password ).to.not.match(/[iloIOS10]/)
