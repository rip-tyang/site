_ = require './_util'
Perlin = require './_perlin'
AsideEffect = require './_aside_effect'

class AsideEffectPerlin extends AsideEffect
  @name: 'perlin'
  constructor: (option = {}) ->
    super
    @p = new Perlin()
    @smallCanvas = document.createElement 'canvas'
    @sCtx = @smallCanvas.getContext '2d'
    @z = 0
    @zoom = 4
    @perlinRatio = 10
    @onResize()

  tick: =>
    super
    i = -1
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    while ++i < @smallCanvas.width
      j = -1
      while ++j < @smallCanvas.height
        v = @p.getNoise(i / @perlinRatio, j / @perlinRatio, @z)
        cell = (i + j * @smallCanvas.width) * 4
        @data[cell + 3] = (1 + v) * 64
    @sCtx.putImageData @image, 0, 0
    @ctx.drawImage @smallCanvas, 0, 0, @canvas.width, @canvas.height
    @update()

  reset: =>
    super
    @

  switch: =>
    @toggle()

  update: =>
    @z += 0.01

  onResize: =>
    super
    @smallCanvas.width = ~~(@canvas.width / @zoom)
    @smallCanvas.height = ~~(@canvas.height / @zoom)
    @image = @ctx.createImageData @smallCanvas.width, @smallCanvas.height
    @data = @image.data
    i = -1
    num = @smallCanvas.width * @smallCanvas.height * 4
    while ++i < num then @data[i] = 255

exports = module.exports = AsideEffectPerlin
