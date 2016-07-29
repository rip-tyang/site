AsideEffect = require './_aside_effect'
_ = require './_util'

# Credit: https://github.com/LeeYiyuan/tetrisai
class Piece
  constructor: (@cells) ->
    @dimension = @cells.length
    @row = 0
    #Centralize
    @column = ~~((10 - @dimension) / 2)

  @fromIndex: (index) ->
    switch index
      # 0
      when 0 then new @([ [1, 1], [1, 1] ])
      # J
      when 1 then new @([
        [1, 0, 0]
        [1, 1, 1]
        [0, 0, 0]
      ])
      # L
      when 2 then new @([
        [0, 0, 1]
        [1, 1, 1]
        [0, 0, 0]
      ])
      # Z
      when 3 then new @([
        [1, 1, 0]
        [0, 1, 1]
        [0, 0, 0]
      ])
      # S
      when 4 then new @([
        [0, 1, 1]
        [1, 1, 0]
        [0, 0, 0]
      ])
      # T
      when 5 then new @([
        [0, 1, 0]
        [1, 1, 1]
        [0, 0, 0]
      ])
      # I
      when 6 then new @([
        [0, 0, 0, 0]
        [1, 1, 1, 1]
        [0, 0, 0, 0]
        [0, 0, 0, 0]
      ])

  clone: =>
    piece = new Piece(_.cloneArray(@cells))
    piece.row = @row
    piece.column = @column
    piece

  # true for clockwise
  # false for counter-clockwise
  rotate: (type) =>
    switch type
      when true then _.rotateArrayClockwise @cells
      when false then _.rotateArrayCounterClockwise @cells
      else throw Error "Invalid rotate parameter: #{type}"
    @

  # calculate offset from another piece
  calcOffset: (p) =>
    return {
      rowOffset: @row - p.row
      columnOffset: @column - p.column
    }


class RandomPieceGenerator
  constructor: ->
    @bag = [0...7]
    @init()

  init: ->
    _.shuffle @bag
    @iterator = 0
    @

  next: ->
    @init() if @iterator is @bag.length
    Piece.fromIndex @bag[@iterator++]

class Grid
  constructor: (@rowSize, @colSize) ->
    @cells = _.arr @rowSize, @colSize

  # too memory intensive
  # clone: =>
  #   new Grid @rowSize, @colSize, @cells

  isLine: (row) =>
    for i in [0...@colSize]
      return false if @cells[row][i] is 0
    return true

  isEmptyRow: (row) =>
    for i in [0...@colSize]
      return false if @cells[row][i] is 1
    return true

  # return how many lines cleared
  clearLines: =>
    dis = 0
    for i in [@rowSize - 1..0]
      if @isLine(i)
        ++dis
        for j in [0...@colSize]
          @cells[i][j] = 0
      else if dis > 0
        for j in [0...@colSize]
          @cells[i + dis][j] = @cells[i][j]
          @cells[i][j] = 0
    dis

  overflowed: =>
    !@isEmptyRow(0) || !@isEmptyRow(1)

  calcFeatures: =>
    rowCount = _.arr @rowSize
    colHeight = _.arr @colSize
    bumpiness = 0
    holes = 0
    lines = 0

    for j in [0...@colSize]
      block = false
      for i in [0...@rowSize]
        block |= @cells[i][j] is 1
        rowCount[i] += @cells[i][j]
        colHeight[j] ||= (@rowSize - i) if @cells[i][j] is 1
        holes += (1 - @cells[i][j]) if block

    for i in [0...@rowSize]
      ++lines if rowCount[i] is @colSize

    for i in [0...@colSize - 1]
      bumpiness += Math.abs(colHeight[i] - colHeight[i + 1])

    cumulatedHeight = colHeight.reduce (p, c) -> p + c

    [cumulatedHeight, lines, holes, bumpiness]

  addPiece: (p) =>
    for i in [0...p.dimension]
      for j in [0...p.dimension]
        r = p.row + i
        c = p.column + j
        @cells[r][c] = 1 if p.cells[i][j] is 1 and r > 0
    @
  removePiece: (p) =>
    for i in [0...p.dimension]
      for j in [0...p.dimension]
        r = p.row + i
        c = p.column + j
        @cells[r][c] = 0 if p.cells[i][j] is 1 and r > 0
    @

  valid: (p) =>
    for i in [0...p.dimension]
      for j in [0...p.dimension]
        r = p.row + i
        c = p.column + j
        if p.cells[i][j] is 1 &&
          (c >= @colSize || r >= @rowSize || @cells[r][c] isnt 0)
            return false
    return true

  canMoveDown: (p) =>
    for i in [0...p.dimension]
      for j in [0...p.dimension]
        r = p.row + i + 1
        c = p.column + j
        if p.cells[i][j] is 1 && r >= 0 &&
          (r >= @rowSize || @cells[r][c] isnt 0)
            return false
    return true

  canMoveLeft: (p) =>
    for i in [0...p.dimension]
      for j in [0...p.dimension]
        r = p.row + i
        c = p.column + j - 1
        if p.cells[i][j] is 1 &&
          (c < 0 || @cells[r][c] isnt 0)
            return false
    return true

  canMoveRight: (p) =>
    for i in [0...p.dimension]
      for j in [0...p.dimension]
        r = p.row + i
        c = p.column + j + 1
        if p.cells[i][j] is 1 &&
          (c >= @colSize || @cells[r][c] isnt 0)
            return false
    return true

  rotateOffset: (p) =>
    _p = p.clone()
    _p.rotate true
    return _p.calcOffset p if @valid _p

    initRow = _p.row
    initCol = _p.column

    for i in [0..._p.dimension - 1]
      _p.column = initCol + i
      return _p.calcOffset p if @valid _p

      for j in [0..._p.dimension - 1]
        _p.row = initRow - j
        return _p.calcOffset p if @valid _p

      _p.row = initRow
    _p.column = initCol

    for i in [0..._p.dimension - 1]
      _p.column = initCol - i
      return _p.calcOffset p if @valid _p

      for j in [0..._p.dimension - 1]
        _p.row = initRow - j
        return _p.calcOffset p if @valid _p

      _p.row = initRow
    _p.column = initCol

    return null

class AI
  # weights: coefficients for AI algo
  # heightW
  # linesW
  # holesW
  # bumpinessW
  constructor: (@weights) ->
    @

  # arrP, possible piece
  best: (grid, currP) =>
    bestPiece = null
    highestScore = -Infinity
    originalP = currP.clone()

    for rotation in [0...4]
      _p = originalP.rotate(true).clone()
      --_p.column while grid.canMoveLeft _p

      while grid.valid _p
        _tp = _p.clone()
        ++_tp.row while grid.canMoveDown _tp

        grid.addPiece _tp

        score = grid.calcFeatures().reduce((p, c, i) =>
          p + c * @weights[i]
        , 0)
        grid.removePiece _tp

        if score > highestScore
          bestPiece = _p.clone()
          highestScore = score

        ++_p.column

    return { piece: bestPiece, score: highestScore }

class AsideEffectTetris extends AsideEffect
  @name: 'tetris'
  constructor: (option = {}) ->
    super
    @width = @canvas.width
    @height = @canvas.height
    @origin =
      x: 0
      y: 0
    @gap = 2
    @cellSize
    @onResize()

    @grid = new Grid(22, 10)
    @rpg = new RandomPieceGenerator()
    @ai = new AI([-0.51006, 0.760666, -0.35663, -0.184483])
    @aiActive = true
    @currentPieces = [@rpg.next(), @rpg.next()]
    @currentIdx = 0
    @currP = if @aiActive then @aiMove() else @currentPieces[@currentIdx]
    @score = 0
    @alive = true
    @reset()

  reset: =>
    return @ if @alive
    @alive = true
    @grid = new Grid(22, 10)
    @aiActive = true
    @currentPieces = [@rpg.next(), @rpg.next()]
    @currentIdx = 0
    @currP = if @aiActive then @aiMove() else @currentPieces[@currentIdx]
    @score = 0
    @

  play: =>
    @loopId = window.requestInterval
      delay: @delay
      elem: @canvas
      fn: @tick
    @

  tick: =>
    @gravity()
    return @pause() unless @alive
    @grid.addPiece @currP
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'

    for i in [2...@grid.rowSize]
      for j in [0...@grid.colSize]
        if @grid.cells[i][j] is 1
          @ctx.fillRect(@origin.x + @cellSize * j + @gap * (j + 1),
            @origin.y + @cellSize * (i - 2) + @gap * (i - 1),
            @cellSize,
            @cellSize)

    @grid.removePiece @currP

  switch: =>
    @aiActive = !@aiActive

  gravity: =>
    if @grid.canMoveDown @currP
      ++@currP.row
    else
      @setCurrP()
    @

  setCurrP: =>
    @grid.addPiece @currP
    @score += @grid.clearLines()
    if @grid.overflowed()
      @alive = false
      return

    @currentPieces[@currentIdx] = @rpg.next()
    @currP = if @aiActive then @aiMove() else @currentPieces[@currentIdx]

  aiMove: =>
    res = { piece: null, score: -Infinity }
    @currentPieces.forEach (p, i) =>
      tmp  = @ai.best @grid, p
      if tmp.score > res.score
        res = tmp
        @currentIdx = i
    res.piece

  onResize: =>
    super
    @width = @canvas.width
    @height = @canvas.height
    if @width * 2 > @height
      @cellSize = ((@height - @gap) / 20) - @gap
    else
      @cellSize = ((@width - @gap) / 10) - @gap
    @origin.x = (@width - @cellSize * 10 - @gap * 11) / 2
    @origin.y = @height - @cellSize * 20 - @gap * 21

exports = module.exports = AsideEffectTetris
