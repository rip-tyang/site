AsideEffect = require './_aside_effect'

class AsideEffectSnow extends AsideEffect
  constructor: (@canvas) ->
    super
    @nums = 52
    @angle = 0
    @width = @canvas.width
    @height = @canvas.height
    @particles = Array.apply(null, Array(@nums)).map () =>
      x: Math.random()*@width
      y: Math.random()*@height
      r: Math.random()*4 + 1
      d: Math.random()*@nums
    @onResize()

  tick: () =>
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'
    @ctx.beginPath()

    for p in @particles
      @ctx.moveTo p.x, p.y
      @ctx.arc p.x, p.y, p.r, 0, Math.PI*2, true

    @ctx.fill()
    @update()

  update: () =>
    @angle += 0.02 * Math.random()
    for p in @particles
      p.y += Math.cos(@angle+p.d) + 1 + p.r/2
      p.x += Math.sin(@angle) * 2

      if p.x > @width + 5 || p.x < -5 || p.y > @height
        if Math.random() > 0.33
          p.x = Math.random()*@width
          p.y = -10
        else if Math.sin(@angle) > 0
          p.x = -5
          p.y = Math.random()*@height
        else
          p.x = @width + 5
          p.y = Math.random()*@height

  onResize: () =>
    super
    for p in @particles
      p.x = p.x / @width * @canvas.width
      p.y = p.y / @height * @canvas.height
    @width = @canvas.width
    @height = @canvas.height

exports = module.exports = AsideEffectSnow
