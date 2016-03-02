Util = require './_util'

class AsideEffect
  constructor: (option = {}) ->
    @canvas = option.canvas
    throw Error 'No Canvas Attached' unless @canvas?

    @ctx = @canvas.getContext '2d'

    # switch effect mod
    @switchElem = option.switch

    # play and pause
    @toggleElem = option.toggle

    @delay
    @loopId

    window.addEventListener 'resize', @onResize, false
    @switchElem.addEventListener 'click', @switch, false if @switchElem?
    @toggleElem.addEventListener 'click', @toggle, false if @toggleElem?

  tick: =>
    @

  play: =>
    @loopId = window.requestInterval
      delay: @delay
      elem: @canvas
      fn: @tick

  reset: =>
    @

  pause: =>
    @loopId = window.clearRequestInterval @loopId
    @loopId = null
    @

  switch: =>
    @

  toggle: =>
    if @loopId then @pause() else @play()

  onResize: =>
    rect = @canvas.getBoundingClientRect()
    @canvas.width = rect.width
    @canvas.height = rect.height

exports = module.exports = AsideEffect
