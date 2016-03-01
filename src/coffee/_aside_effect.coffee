Util = require './_util'

class AsideEffect
  constructor: (option = {}) ->
    @canvas = option.canvas
    throw Error 'No Canvas Attached' unless @canvas?

    @animated = true
    @ctx = @canvas.getContext '2d'

    # switch effect mod
    @switchElem = option.switch

    # play and pause
    @toggleElem = option.toggle

    @loopId

    window.addEventListener 'resize', @onResize, false
    @switchElem.addEventListener 'click', @switch, false if @switchElem?
    @toggleElem.addEventListener 'click', @toggle, false if @toggleElem?

  tick: =>
    @animated

  play: =>
    @animated = true
    @loopId = window.requestInterval
      elem: @canvas
      fn: @tick

  pause: =>
    @animated = false
    @loopId = null

  switch: =>
    @

  toggle: =>
    if @loopId then @pause() else @play()

  onResize: =>
    rect = @canvas.getBoundingClientRect()
    @canvas.width = rect.width
    @canvas.height = rect.height

exports = module.exports = AsideEffect
