_ = require './_util'
Vector2 = require './_vector2'
AsideEffect = require './_aside_effect'

MAX_TRAJECTORY_NUM = 500
G = 5e-2
PI2 = Math.PI * 2
ROOT2 = Math.sqrt 2
ROOT3 = Math.sqrt 3
DELTA = .0002

# draw circle functions
DRAW_CIRCLE = (ctx) ->
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y, @r, 0, PI2
  ctx.fill()

DRAW_HALF_CIRCLE = (ctx) ->
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y, @r, 0, PI2
  ctx.stroke()
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y, @r, 0, Math.PI
  ctx.fill()

DRAW_CIRCLE_WITH_RING = (ctx) ->
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y, @r, 0, PI2
  ctx.fill()
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y, @r * 1.5, 0, PI2
  ctx.stroke()

DRAW_CIRCLE_WITH_THREE_CIRCLE_INSIDE = (ctx) ->
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y, @r, 0, PI2
  ctx.stroke()
  ratio = 1 + 2 / ROOT3
  sr = @r / ratio
  ctx.beginPath()
  ctx.arc @pos.x, @pos.y - sr * 2 / ROOT3, sr, 0, PI2
  ctx.fill()
  ctx.beginPath()
  ctx.arc @pos.x - sr, @pos.y + sr / ROOT3, sr, 0, PI2
  ctx.fill()
  ctx.beginPath()
  ctx.arc @pos.x + sr, @pos.y + sr / ROOT3, sr, 0, PI2
  ctx.fill()

DRAW_CIRCLE_WITH_FOUR_CIRCLE_INSIDE = (ctx) ->
  ctx.beginPath()
  ctx.moveTo @pos.x, @pos.y
  ctx.arc @pos.x, @pos.y, @r, 0, PI2
  ctx.stroke()
  sr = @r / (1 + ROOT2)
  ctx.beginPath()
  ctx.moveTo @pos.x + @r / 2, @pos.y
  ctx.arc @pos.x + @r - sr, @pos.y, sr, 0, PI2
  ctx.fill()
  ctx.beginPath()
  ctx.moveTo @pos.x - @r / 2, @pos.y
  ctx.arc @pos.x - @r + sr, @pos.y, sr, 0, PI2
  ctx.fill()
  ctx.beginPath()
  ctx.moveTo @pos.x, @pos.y + @r / 2
  ctx.arc @pos.x, @pos.y + @r - sr, sr, 0, PI2
  ctx.fill()
  ctx.beginPath()
  ctx.moveTo @pos.x, @pos.y - @r / 2
  ctx.arc @pos.x, @pos.y - @r + sr, sr, 0, PI2
  ctx.fill()

DRAW_CIRCLE_TRIANGLE_INSIDE = (ctx) ->
  ctx.beginPath()
  ctx.moveTo @pos.x, @pos.y
  ctx.arc @pos.x, @pos.y, @r, 0, PI2
  ctx.stroke()
  ctx.beginPath()
  ctx.moveTo @pos.x, @pos.y - @r
  ctx.lineTo @pos.x - @r * ROOT3 / 2, @pos.y + @r / 2, @r, 0, PI2
  ctx.lineTo @pos.x + @r * ROOT3 / 2, @pos.y + @r / 2, @r, 0, PI2
  ctx.lineTo @pos.x, @pos.y - @r
  ctx.fill()

class AsideEffectThreeBody extends AsideEffect
  @name: 'threebody'
  constructor: (option = {}) ->
    super
    # first layer is to draw random walk traces
    @firstLayer = document.createElement 'canvas'
    @fCtx = @firstLayer.getContext '2d'
    @firstLayer.width = @width = @canvas.width
    @firstLayer.height = @height = @canvas.height
    @onResize()
    @scenes = []
    @currentScene = 0

    # Scene
    bodies = []
    commonM = 2000
    v1 = .0844451728
    v2 = .2960600146
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 + 120)
      speed: new Vector2(-2 * v1, -2 * v2)
      m: commonM
      r: 4
      draw: DRAW_CIRCLE_WITH_RING
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 - 100, @height / 2 + 120)
      speed: new Vector2(v1, v2)
      m: commonM
      r: 4
      draw: DRAW_CIRCLE
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 + 100, @height / 2 + 120)
      speed: new Vector2(v1, v2)
      m: commonM
      r: 4
      draw: DRAW_HALF_CIRCLE
    }))
    @scenes.push(new Scene({
      bodies: bodies
      width: @width
      height: @height
    }))

    # Scene
    commonM = 20000
    bodies = []
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 + 260)
      speed: new Vector2(1, 0)
      m: commonM
      draw: DRAW_CIRCLE_WITH_RING
      r: 5
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 - 80 * ROOT3, @height / 2 + 20)
      speed: new Vector2(-.5, ROOT3 / 2)
      m: commonM
      draw: DRAW_HALF_CIRCLE
      r: 5
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 + 80 * ROOT3, @height / 2 + 20)
      speed: new Vector2(-.5, -ROOT3 / 2)
      m: commonM
      r: 5
    }))
    @scenes.push(new Scene({
      bodies: bodies
      width: @width
      height: @height
    }))

    # Scene
    bodies = []
    commonM = 2000
    v1 = .3471168881
    v2 = .5327249454
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 + 120)
      speed: new Vector2(-2 * v1, -2 * v2)
      m: commonM
      r: 4
      ideal: true
      draw: DRAW_CIRCLE_WITH_RING
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 - 100, @height / 2 + 120)
      speed: new Vector2(v1, v2)
      m: commonM
      r: 4
      ideal: true
      draw: DRAW_CIRCLE
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 + 100, @height / 2 + 120)
      speed: new Vector2(v1, v2)
      m: commonM
      r: 4
      ideal: true
      draw: DRAW_HALF_CIRCLE
    }))
    @scenes.push(new Scene({
      bodies: bodies
      width: @width
      height: @height
    }))

    # Scene
    bodies = []
    commonM = 2000
    v1 = .4644451728
    v2 = .3960600146
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 + 120)
      speed: new Vector2(-2 * v1, -2 * v2)
      m: commonM
      r: 4
      ideal: true
      draw: DRAW_CIRCLE_WITH_RING
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 - 100, @height / 2 + 120)
      speed: new Vector2(v1, v2)
      m: commonM
      r: 4
      ideal: true
      draw: DRAW_CIRCLE
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2 + 100, @height / 2 + 120)
      speed: new Vector2(v1, v2)
      m: commonM
      r: 4
      ideal: true
      draw: DRAW_HALF_CIRCLE
    }))
    @scenes.push(new Scene({
      bodies: bodies
      width: @width
      height: @height
    }))

    # Scene
    bodies = []
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 - 80)
      speed: new Vector2(-2, 0)
      m: 10
      r: 4
      draw: DRAW_CIRCLE_WITH_RING
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 + 20)
      speed: new Vector2(1, 0)
      m: 20000
      r: 20
      draw: DRAW_CIRCLE
    }))
    bodies.push(new Body({
      pos: new Vector2(@width / 2, @height / 2 + 220)
      speed: new Vector2(-1.25, 0)
      m: 16000
      r: 12
      draw: DRAW_HALF_CIRCLE
    }))
    @scenes.push(new Scene({
      bodies: bodies
      width: @width
      height: @height
    }))


  tick: =>
    super
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @scenes[@currentScene].tick @ctx, @fCtx
    @ctx.drawImage @firstLayer, 0, 0

  switch: =>
    @currentScene = ( @currentScene + 1 ) % @scenes.length
    @fCtx.clearRect 0, 0, @canvas.width, @canvas.height
    # TODO switch between scene

  reset: =>
    super
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'
    @ctx.strokeStyle = 'rgba(255,255,255,0.5)'
    @fCtx.strokeStyle = 'rgba(255,255,255,0.25)'
    @

  onResize: =>
    super
    @firstLayer.height = @height = @canvas.height
    @firstLayer.width = @width = @canvas.width

class Body
  IdCounter = 0

  constructor: (option = {}) ->
    @id = IdCounter++
    @m = option.m || 1
    @r = option.r || Math.sqrt @m
    @pos = option.pos || new Vector2(0, 0)
    @speed = option.speed || new Vector2(0, 0)
    @acc = option.acc || new Vector2(0, 0)
    @draw = option.draw || DRAW_CIRCLE.bind @
    @ideal = option.ideal || false
    @prevpos = @pos

  drawBody: (ctx, fCtx) =>
    @draw ctx
    @drawTrajectory fCtx

  update: =>
    @pos = @speed.times(DELTA).add(@pos)
    @speed = @acc.times(DELTA).add(@speed)

  drawTrajectory: (ctx) =>
    ctx.beginPath()
    ctx.moveTo @prevpos.x, @prevpos.y
    ctx.lineTo @pos.x, @pos.y
    ctx.stroke()
    @prevpos = @pos

class Scene
  constructor: (option = {}) ->
    @bodies = option.bodies || []
    @width = option.width || 100
    @height = option.height || 100
    @updateRate = option.updateRate || 2000

  tick: (ctx, fCtx) =>
    @update()
    @bodies.forEach (body) -> body.drawBody ctx, fCtx

  update: =>
    idx = 0
    while idx++ < @updateRate
      @applyBoundary()
      @applyAttraction()
      @bodies.forEach (body) -> body.update()

  applyBoundary: =>
    @bodies.forEach (body) =>
      if body.pos.x < body.r && body.speed.x < 0 ||
         body.pos.x > @width - body.r && body.speed.x > 0
        body.speed.x = -body.speed.x
      if body.pos.y < body.r && body.speed.y < 0 ||
         body.pos.y > @height - body.r && body.speed.y > 0
        body.speed.y = -body.speed.y

  applyAttraction: =>
    @bodies.forEach (body) =>
      body.acc = new Vector2(0, 0)
      @bodies.forEach (other) ->
        if body.id != other.id
          rd = other.pos.minus body.pos
          rSum = if body.ideal then 0 else body.r
          rSum += if other.ideal then 0 else other.r
          dis = Math.max rd.magnitude, rSum
          r2 = dis * dis
          body.acc = rd.std().times(other.m * G / r2).add(body.acc)

module.exports = AsideEffectThreeBody
