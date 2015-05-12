describe 'App.Tags', ->
  tags = null

  beforeEach ->
    tags = new App.Tags

  it 'should get tags', ->
    fn = -> tags.fetch()
    expect( fn ).to.not.throwError()

  it 'should add new tags', ->
    fn = -> tags.update( [ 'tag' ] )
    expect( fn ).to.not.throwError()

  it 'should not duplicate tags', ->
    tags.update( [ 'tag1', 'tag1' ] )
    expect( tags ).to.have.length(1)
    tags.update( [ 'tag1' ] )
    expect( tags ).to.have.length(1)

  it 'should remove tags', ->
    tags.update( [ 'tag1', 'tag2', 'tag3' ] )
    expect( tags ).to.have.length(3)
    tags.update( [ 'tag1', 'tag2' ] )
    expect( tags ).to.have.length(2)

  describe 'serialization', ->
    beforeEach -> tags.update( [ 'tag1', 'tag2', 'tag3' ] )

    it 'should serialize to json', ->
      json = tags.toJSON()
      expect( json ).to.be.an('array')
      expect( json[0] ).to.be.an('object')
      expect( json[0].name ).to.eql('tag1')

    it 'should include colors', ->
      json = tags.toJSON()
      expect( json[0].color ).to.eql(App.Tags.COLORS_BY_POSITION[0])

    it 'should indicate active tags', ->
      shouldBeActive = tags.pluck('id')[0]
      json = tags.toJSON( [ shouldBeActive ] )
      expect( json[0].active ).to.be.ok()
      expect( json[1].active ).to.not.be.ok()
