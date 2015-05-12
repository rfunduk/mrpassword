# Dropbox Datastore API Migration Service
############################################
#
# This is a temporary service that allows migration of data from
# the deprecated Dropbox Datastore API to using a flat JSON file
# in an application folder instead.
#
# Since Dropbox doesn't allow changing permissions on apps, there is
# a new app and I've hard-coded my old API key in here. If you've
# been running Mr.Password yourself, you'll need to drop your own
# original API key in here and configure the new one as specified
# in the README -- Sorry :/

class App.Services.Migrator
  constructor: ->
    @oldClient = new Dropbox.Client key: 'lxkl09lmt4f7gld'

  run: ( cb ) ->
    @oldClient.authenticate ( error, oldClient ) =>
      if error
        alert("Sorry! Dropbox authentication failure: #{error}")
        return
      else if oldClient.isAuthenticated()
        manager = oldClient.getDatastoreManager()
        manager.openDefaultDatastore ( error, datastore ) =>
          if error
            cb error
          else
            data = @_dataFromDatastore( datastore )

            console.log 'Generated migration data:', data

            window.dropboxApi.data = data
            window.dropboxApi.save()
            window.localStorage.setItem( 'noMigrationPrompt', true )
            cb( null, data )

  _dataFromDatastore: ( datastore ) ->
    tags = _.map datastore.getTable('tags').query(), ( r ) ->
      obj = r.getFields()
      obj.id = r.getId()
      obj

    data =
      passwords:  _.map datastore.getTable('passwords').query(), ( r ) ->
        obj = r.getFields()
        obj.id = r.getId()
        obj.tags = if obj.tags
          tagNames = obj.tags.toArray()
          selectedTags = _.filter tags, ( tag ) -> _.contains(tagNames, tag.name)
          _.pluck selectedTags, 'id'
        else
          []
        obj

      tags: tags

      settings: _.map datastore.getTable('settings').query(), ( r ) ->
        obj = r.getFields()
        obj.id = r.getId()
        obj
