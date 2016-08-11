_ = require './_util'
AsideEffect = require './_aside_effect'

class AsideEffectRandomWalk extends AsideEffect
  @name: 'random-walk'

  constructor: (options = {}) ->
    super
    # first layer is to draw random walk traces
    # so that it won't be erased when pausing
    @firstLayer = document.createElement 'canvas'
    @fCtx = @firstLayer.getContext '2d'
    @firstLayer.width = @width = @canvas.width
    @firstLayer.height = @height = @canvas.height

    @cellSize = 8
    @cursorExpandCurrSize = @cursorSize = 4
    @cursorExpandSize = 160
    @curr = { x: 0, y: 0 }
    @cursor = { x: 0, y: 0 }
    @isPaused = false

    # how many ticks until before updating the cursor
    # too small will cause visually flicking
    @showCursorShreshold = @showCursorCounter = 2

    @onResize()
    @curr = { x: ~~(@width * .5), y: ~~(@height * .7) }

  switch: =>
    @isPaused = !@isPaused

  tick: =>
    super
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height

    if !@isPaused
      @fCtx.beginPath()
      @fCtx.moveTo @curr.x, @curr.y
      rand = ((~~(Math.random() * 2)) * 2 - 1) * @cellSize
      axis = if Math.random() > 0.5 then 'x' else 'y'
      @curr[axis] += rand
      @fCtx.lineTo @curr.x, @curr.y
      @curr.x = (@curr.x + @width) % @width
      @curr.y = (@curr.y + @height) % @height
      @fCtx.stroke()
      if @showCursorCounter is @showCursorShreshold
        @showCursorCounter = -1
        @cursor.x = @curr.x - @cursorSize
        @cursor.y = @curr.y - @cursorSize
      @showCursorCounter++
    else
      alpha = @cursorExpandSize - @cursorExpandCurrSize
      alpha /= @cursorExpandSize - @cursorSize
      alpha = alpha * .9 + .1
      @ctx.strokeStyle = "rgba(255, 255, 255, #{alpha})"
      @ctx.beginPath()
      @cursorExpandCurrSize += @cursorExpandSize / 120
      if @cursorExpandCurrSize > @cursorExpandSize
        @cursorExpandCurrSize = @cursorSize
      @ctx.arc(
        @cursor.x,
        @cursor.y,
        @cursorExpandCurrSize,
        0,
        2 * Math.PI)
      @ctx.stroke()
      @ctx.strokeStyle = 'rgba(255, 255, 255, 1)'

    @ctx.beginPath()
    @ctx.arc(
      @cursor.x,
      @cursor.y,
      @cursorSize,
      0,
      2 * Math.PI)
    @ctx.stroke()
    @ctx.drawImage @firstLayer, 0, 0

  reset: =>
    super
    @fCtx.strokeStyle = 'rgba(255, 255, 255, .2)'
    @ctx.strokeStyle = 'rgba(255, 255, 255, 1)'
    @

  onResize: =>
    super
    @firstLayer.width = @width = @canvas.width
    @firstLayer.height = @height = @canvas.height
    @curr.x = ((@curr.x % @width) + @width) % @width
    @curr.y = ((@curr.y % @height) + @height) % @height


exports = module.exports = AsideEffectRandomWalk
