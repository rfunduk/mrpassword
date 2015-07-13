class App.Views.Settings extends Backbone.View
  className: 'setup'
  events:
    'change .action-toggle-remember-master': 'toggleRememberMaster'
    'click .action-purge-all-data': 'considerPurgeAllData'

  considerPurgeAllData: ( e ) ->
    target = @$('.action-purge-all-data')
    if target.hasClass('confirm-purge')
      window.dropboxApi.client.remove('@@vaultFileName.json')
      App.purged = true
      App.router.navigate( 'logout', trigger: true )
    else
      target.addClass('confirm-purge').find('.message').text("Are you REALLY sure?")
      setTimeout(
        -> target.removeClass('confirm-purge').find('.message').text("Goodbye, Mr. Password!")
        5000
      )

  remove: ->
    @masterView.remove() if @masterView
    super()

  toggleRememberMaster: ->
    checkbox = @$('.remember-master')
    remember = checkbox.is(':checked')
    App.master = null unless remember
    App.settings.setting( 'rememberMaster', remember )

  render: ->
    hasMaster = App.settings.hasMasterPassword()

    @$el.html App.Templates.routes.setup(
      rememberMaster: App.settings.setting('rememberMaster')
      hasMaster: hasMaster
    )

    masterMode = if hasMaster then 'Change' else 'Set'
    @masterView = new App.Views.Setting["#{masterMode}MasterPassword"]
    @$('.master-password-interface').html( @masterView.render().el )

    @backupView = new App.Views.Setting.Backup
    @$('.backup-data-interface').html( @backupView.render().el )

    @tagsView = new App.Views.Setting.Tags
    @$('.tags-interface').html( @tagsView.render().el )

    @
