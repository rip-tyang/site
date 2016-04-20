Util = require './_util'
AsideEffect = require './_aside_effect'

class AsideEffectRandomWalk extends AsideEffect
  @name: 'random-walk'
  @curr: {x: 0, y: 0}
  @width = @canvas.width
  @height = @canvas.height

  constructor: (options = {}) ->
    super
    @onResize()

  posToCanvas: =>
    
  tick: =>
    @ctx.fillStyle = 'rgba(255,255,255,0.1)'
    @ctx.beginPath()

    for p in @particles
      @ctx.moveTo p.x, p.y
      @ctx.arc p.x, p.y, p.r, 0, Math.PI*2, true

    @ctx.fill()
    @update()

  onResize: =>
    super


exports = module.exports = AsideEffectRandomWalk
