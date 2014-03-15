describe 'App.Services.Encryptor', ->
  it 'should encrypt data', ->
    fn = -> App.sjcl.encrypt('password', 'test')
    expect( fn ).to.not.throwError()

  it 'should decrypt data', ->
    encrypted = App.sjcl.encrypt('password', 'test')
    decrypted = App.sjcl.decrypt('password', encrypted)
    expect( decrypted ).to.eql( 'test' )
