class App.Tag extends Backbone.Model
  table: -> _.result( @collection, 'table' )

class App.Tags extends Backbone.Collection
  @COLORS_BY_POSITION = [
    '#555555' # gray
    '#59378b' # purple
    '#5cb85c' # green
    '#5bc0de' # light blue
    '#d9534f' # red
    '#f0ad4e' # orange
    '#113c6c' # blue
    '#000000' # black
  ]

  model: App.Tag
  table: 'tags'
  comparator: 'position'

  update: ( newTags ) ->
    oldTags = @indexBy('name')

    # remove tags that are missing now
    @each ( tag ) =>
      unless _.include( newTags, tag.get('name') )
        tag.destroy()
        @remove( tag )

    _.each _.uniq(newTags), ( name, i ) =>
      tag = oldTags[name] || new App.Tag( name: name )
      tag.set position: i
      @push tag
      tag.save()

  toJSON: ( selectedTags=null ) ->
    colors = @constructor.COLORS_BY_POSITION
    @map ( tag, i ) ->
      json = tag.toJSON()
      json.active = _.include( selectedTags, json.id ) if selectedTags
      json.color = colors[i]
      json
