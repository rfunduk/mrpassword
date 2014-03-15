Handlebars.registerHelper 'ifApp', ( key, options ) ->
  if App[key] then options.fn(@) else options.inverse(@)

Handlebars.registerHelper 'ifSetting', ( key, options ) ->
  truthy = App.settings.setting( key )
  if truthy then options.fn(@) else options.inverse(@)

Handlebars.registerHelper 'ifLoggedIn', ( options ) ->
  truthy = App.settings.api.client.isAuthenticated()
  if truthy then options.fn(@) else options.inverse(@)

Handlebars.registerHelper 'ifHasMasterPassword', ( options ) ->
  truthy = App.settings.hasMasterPassword()
  if truthy then options.fn(@) else options.inverse(@)

Handlebars.registerHelper 'ifOnRoute', ( key, options ) ->
  if App.router.onRoute(key) then options.fn(@) else options.inverse(@)

Handlebars.registerHelper 'unlessEmpty', ( array, options ) ->
  if _.isEmpty(array) then options.inverse(@) else options.fn(@)
