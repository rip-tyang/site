_ = require './_util'
AsideEffect = require './_aside_effect'

class AsideEffectSnow extends AsideEffect
  @name: 'snow'
  constructor: (option = {}) ->
    super
    @nums = 52
    @angle = 0
    @mod = 1
    @width = @canvas.width
    @height = @canvas.height
    @particles = _.arr @nums, =>
      x: Math.random() * @width
      y: Math.random() * @height
      r: Math.random() * 4 + 1
      d: Math.random() * @nums
    @onResize()

  tick: =>
    super
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.beginPath()

    for p in @particles
      @ctx.moveTo p.x, p.y
      @ctx.arc p.x, p.y, p.r, 0, Math.PI * 2, true

    @ctx.fill()
    @update()

  reset: =>
    super
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'
    @

  switch: =>
    @mod = -@mod

  update: =>
    @angle += 0.01 * Math.random()
    for p in @particles
      p.y += (Math.cos(@angle + p.d) + 0.5 + p.r / 2) * @mod
      p.x += Math.sin @angle

      if p.x > @width + 5 || p.x < -5 || p.y > @height + 10 || p.y < -10
        if Math.random() > 0.33
          p.x = Math.random() * @width
          p.y = @height / 2
          p.y = p.y - @mod * (10 + p.y)
        else if Math.sin(@angle) > 0
          p.x = -5
          p.y = Math.random() * @height
        else
          p.x = @width + 5
          p.y = Math.random() * @height

  onResize: =>
    super
    for p in @particles
      p.x = p.x / @width * @canvas.width
      p.y = p.y / @height * @canvas.height
    @width = @canvas.width
    @height = @canvas.height

exports = module.exports = AsideEffectSnow
