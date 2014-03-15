class App.Views.Stepped extends Backbone.View
  delegateEvents: ->
    super( _.extend( {}, @events, {
      'click .next-step': 'nextStep'
      'click .prev-step': 'prevStep'
    } ) )

  initialize: ->
    unless _.isArray(@steps)
      @steps = _.map [1..@steps], ( s ) -> "step#{s}"

    @listenTo @, 'stepped.next', @nextStep
    @listenTo @, 'stepped.reset', @reset
    @currentStep = 0
    @reset()

  reset: =>
    @_adjustStep(0)

  runStep: ->
    f = @[@steps[@currentStep]]
    f.apply(@) if f

  _adjustStep: ( newCurrent ) ->
    stepper = @$('.stepped')
    stepper.removeClass("on-step-index-#{@currentStep}")
    @currentStep = newCurrent
    stepper.addClass("on-step-index-#{@currentStep}")
    @runStep()
    return false

  nextStep: ( e ) ->
    if e
      e.stopPropagation()
      e.preventDefault()
    return false if @currentStep >= @steps.length - 1
    @_adjustStep( @currentStep + 1 )

  prevStep: ( e ) ->
    if e
      e.stopPropagation()
      e.preventDefault()
    return false if @currentStep == 0
    @_adjustStep( @currentStep - 1 )
