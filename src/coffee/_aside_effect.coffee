Util = require './_util'

class AsideEffect
  constructor: (option = {}) ->
    @canvas = option.canvas
    throw Error 'No Canvas Attached' unless @canvas?

    @animated = true
    @ctx = @canvas.getContext '2d'
    @switch = option.switch
    @loopId

    window.addEventListener 'resize', @onResize, false
    @switch.addEventListener 'click', @toggle, false if @switch?

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

  toggle: =>
    if @loopId then @pause() else @play()

  onResize: =>
    rect = @canvas.getBoundingClientRect()
    @canvas.width = rect.width
    @canvas.height = rect.height

exports = module.exports = AsideEffect
