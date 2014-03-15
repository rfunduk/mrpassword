class App.Services.PasswordGenerator
  @startValid: 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRTUVWXYZ'
  @valid: @startValid + '23456789!@#$%^&*()_+{}[]-=\\|/?.>,<\'";:`~'

  generate: ( size ) ->
    r = ( set ) ->
      length = set.length
      index = Math.floor( Math.random() * length )
      set.charAt( index )

    chars = []
    chars.push r(@constructor.startValid)

    for _ in [1...size] by 1
      chars.push r(@constructor.valid)

    chars.join('')
