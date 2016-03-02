Util = require './_util'
AsideEffect = require './_aside_effect'

class GameOfLifeBoard
  mask =  [0, 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80, 0x100]

  constructor: (options = {}) ->
    @rowSize = options.rowSize || 40
    @colSize = options.colSize || 20

    # board
    @arr = Util.arr @rowSize+2, @colSize+2, 0
    # status map
    @m = Array(1<<9)
    @buildMap().seed()

  seed: =>
    @emitter()
    @

  emitter: =>
    fig = ['000000000000000000000000100000000000'
      '000000000000000000000010100000000000'
      '000000000000110000001100000000000011'
      '000000000001000100001100000000000011'
      '110000000010000010001100000000000000'
      '110000000010001011000010100000000000'
      '000000000010000010000000100000000000'
      '000000000001000100000000000000000000'
      '000000000000110000000000000000000000'
      ]

    row = 3
    col = 1

    fig.forEach (e, i) =>
      arr = e.split('').map Number
      arr.forEach (v, j) =>
        @arr[row+j][col+i] = v

  osc: =>
    fig = ['00000000000000'
    '00011011000000'
    '00001010100000'
    '00001000010000'
    '01101000001000'
    '01101000000100'
    '00001010000010'
    '00001011000110'
    '00000100000000'
    '00000011111110'
    '00000000000010'
    '00000000110000'
    '00000000110000'
    '00000000000000']
    row = 15
    col = 4
    fig.forEach (e, i) =>
      arr = e.split('').map Number
      arr.forEach (v, j) =>
        @arr[row+i][col+j] = v

  countBit: (x) ->
    res = mask.reduce (p, c) ->
      if c & x then p + 1 else p

  buildMap: =>
    for i in [0...1<<9]
      x = @countBit i
      if i & 0o20
        @m[i] = if x is 3 || x is 4 then 1 else 0
      else
        @m[i] = if x is 3 then 1 else 0
    @

  update: =>
    for i in [1..@rowSize]
      x = 0
      x |= (@arr[i-1][1]&1) << 2
      x |= (@arr[i][1]&1) << 1
      x |= @arr[i+1][1]&1
      for j in [1..@colSize]
        y = 0
        y |= (@arr[i-1][j+1]&1) << 2
        y |= (@arr[i][j+1]&1) << 1
        y |= @arr[i+1][j+1]&1
        x = ((x << 3) | y) & 0o777
        @arr[i][j] |= @m[x] << 1

    for i in [1..@rowSize]
      for j in [1..@colSize]
        @arr[i][j] >>= 1
    @

class AsideEffectGameOfLife extends AsideEffect
  constructor: (options = {}) ->
    super
    @gap = 2
    @rowSize = 40
    @colSize = 20
    @origin =
      x: 0
      y: 0
    @delay = 1000/24
    @g = new GameOfLifeBoard
      rowSize: @rowSize
      colSize: @colSize
    @cellSize
    @onResize()

  switch: =>
    @pause()

  tick: =>
    @g.update()
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'

    for i in [1..@rowSize]
      for j in [1..@colSize]
        if @g.arr[i][j] is 1
          @ctx.fillRect(@origin.x + @cellSize * (j-1) + @gap * j,
            @origin.y + @cellSize * (i-1) + @gap * i,
            @cellSize,
            @cellSize)

  onResize: () =>
    super
    @width = @canvas.width
    @height = @canvas.height
    if @width * 2 > @height
      @cellSize = ((@height-@gap) / 40) - @gap
    else
      @cellSize = ((@width-@gap) / 20) - @gap
    @origin.x = (@width - @cellSize * 20 - @gap * 21) / 2
    @origin.y = @height - @cellSize * 40 - @gap * 41

exports = module.exports = AsideEffectGameOfLife
