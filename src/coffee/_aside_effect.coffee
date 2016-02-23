Util = require './_util'

class AsideEffect
  constructor: (@canvas) ->
    @ctx = @canvas.getContext '2d'
    @fps = 24
    @loopId

    window.addEventListener 'resize', @onResize, false

  tick: () =>
    @

  play: () =>
    @loopId = Util.loopFunc 1000/@fps, @tick

  pause: () =>
    if @loopId
      clearInterval @loopId
      @loopId = null

  onResize: () =>
    rect = @canvas.getBoundingClientRect()
    @canvas.width = rect.width
    @canvas.height = rect.height

exports = module.exports = AsideEffect
