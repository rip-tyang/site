AsideEffect = require './_aside_effect'
Util = require './_util'

# Credit: https://github.com/LeeYiyuan/tetrisai
class Piece
  constructor: (@cells) ->
    @dimension = @cells.length
    @row = 0
    @column = ~~((10 - @dimension) / 2) #Centralize

  @fromIndex: (index) ->
    switch index
      # 0
      when 0 then new @ [ [1, 1], [1, 1] ]
      # J
      when 1 then new @ [
        [1, 0, 0]
        [1, 1, 1]
        [0, 0, 0]
      ]
      # L
      when 2 then new @ [
        [0, 0, 1]
        [1, 1, 1]
        [0, 0, 0]
      ]
      # Z
      when 3 then new @ [
        [1, 1, 0]
        [0, 1, 1]
        [0, 0, 0]
      ]
      # S
      when 4 then new @ [
        [0, 1, 1]
        [1, 1, 0]
        [0, 0, 0]
      ]
      # T
      when 5 then new @ [
        [0, 1, 0]
        [1, 1, 1]
        [0, 0, 0]
      ]
      # I
      when 6 then new @ [
        [0, 0, 0, 0]
        [1, 1, 1, 1]
        [0, 0, 0, 0]
        [0, 0, 0, 0]
      ]

  clone: =>
    piece = new Piece Util.cloneArray(@cells)
    piece.row = @row
    piece.column = @column
    piece

  # true for clockwise
  # false for counter-clockwise
  rotate: (type) =>
    switch type
      when true then Util.rotateArrayClockwise @cells
      when false then Util.rotateArrayCounterClockwise @cells
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
    @iterator = 0
    @init()

  init: ->
    Util.shuffle @bag
    @iterator = 0
    @

  next: ->
    @init() if @iterator is @bag.length-1
    Piece.fromIndex @bag[@iterator++]

class Grid
  constructor: (@rowSize, @colSize) ->
    @cells = Util.arr @rowSize, @colSize, 0

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
    for i in [@rowSize-1..0]
      if @isLine(i)
        ++dis
        for j in [0...@colSize]
          @cells[i][j] = 0
      else if dis > 0
        for j in [0...@colSize]
          @cells[i+dis][j] = @cells[i][j]
          @cells[i][j] = 0
    dis

  overflowed: =>
    !@isEmptyRow(0) || !@isEmptyRow(1)

  height: =>
    for i in [0...@rowSize]
      return @rowSize - i unless @isEmptyRow i
    return 0

  lines: =>
    res = 0
    for i in [0...@rowSize]
      ++res if @isLine i
    res

  holes: =>
    res = 0
    for i in [0...@colSize]
      block = false
      for j in [0...@rowSize]
        if @cells[i][j] is 1
          block = true
        else if block
          ++res
    res

  # blockades: =>
  #   res = 0
  #   for i in [0...@colSize]
  #     hole = false
  #     for j in [@rowSize-1..0]
  #       if @cells[i][j] is 1
  #         hole = true
  #       else if hole
  #         ++res
  #   res

  columnHeight: (col) =>
    for i in [0...@rowSize]
      return @rowSize - i unless @cells[i][col] is 0
    return 0

  aggregateHeight: =>
    res = 0
    for i in [0...@colSize]
      res += @columnHeight i
    res

  bumpiness: =>
    res = 0
    for i in [0...@colSize-1]
      res += Math.abs(@columnHeight(i) - @columnHeight(i+1))
    res

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

    for i in [0..._p.dimension-1]
      _p.column = initCol + i
      return _p.calcOffset p if @valid _p

      for j in [0..._p.dimension-1]
        _p.row = initRow - j
        return _p.calcOffset p if @valid _p

      _p.row = initRow
    _p.column = initCol

    for i in [0..._p.dimension-1]
      _p.column = initCol - i
      return _p.calcOffset p if @valid _p

      for j in [0..._p.dimension-1]
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

  # arrP, possible piece
  best: (grid, currP) =>
    best = null
    highestScore = Math.max()
    originalP = currP.clone()

    for rotation in [0...4]
      _p = originalP.rotate(true).clone()

      --_p.column while grid.canMoveLeft _p

      while grid.valid _p
        _tp = _p.clone()
        ++_tp.row while grid.canMoveDown _tp

        grid.addPiece _tp

        score = [ grid.aggregateHeight()
          grid.lines()
          grid.holes()
          grid.bumpiness()]
        score = score.map (e, i) => e*@weights[i]
        score = score.reduce (p, c) -> p + c
        grid.removePiece _tp

        if score > highestScore
          best = _p.clone()
          highestScore = score

        ++_p.column

    return {piece: best, score: highestScore }

class AsideEffectTetris extends AsideEffect
  constructor: (option = {})->
    super
    @width = @canvas.width
    @height = @canvas.height
    @origin =
      x: 0
      y: 0
    @gap = 2
    @cellSize
    @onResize()

    @grid = new Grid 22, 10
    @rpg = new RandomPieceGenerator
    @ai = new AI [-0.51006, 0.760666, -0.35663, -0.184483]
    @aiActive = true
    @currentPieces = [@rpg.next(), @rpg.next()]
    @currP = if @aiActive then @aiMove() else @currentPieces[0]
    @score = 0
    @reset()

  reset: =>
    @alive = true
    @

  tick: =>
    @gravity()
    return unless @alive
    @grid.addPiece @currP
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'

    for i in [2...@grid.rowSize]
      for j in [0...@grid.colSize]
        if @grid.cells[i][j] is 1
          @ctx.fillRect(@origin.x + @cellSize * j + @gap * (j+1),
            @origin.y + @cellSize * (i-2) + @gap * (i-1),
            @cellSize,
            @cellSize)

    @grid.removePiece @currP

  pause: =>
    super
    @alive = false

  switch: =>
    @aiActive = !@aiActive

  gravity: =>
    if @grid.canMoveDown @currP
      ++@currP.row
    else
      @setCurrP()

  setCurrP: =>
    @grid.addPiece @currP
    @score += @grid.clearLines()
    @pause() if @grid.overflowed()

    @currentPieces.shift()
    @currentPieces.push @rpg.next()
    @currP = if @aiActive then @aiMove() else @currentPieces[0]

  aiMove: =>
    res = {best: null, score: Math.max()}
    for piece in @currentPieces
      tmp  = @ai.best @grid, piece
      res = tmp if tmp.score > res.score
    res.piece

  onResize: () =>
    super
    @width = @canvas.width
    @height = @canvas.height
    if @width * 2 > @height
      @cellSize = ((@height-@gap) / 20) - @gap
    else
      @cellSize = ((@width-@gap) / 10) - @gap
    @origin.x = (@width - @cellSize * 10 - @gap * 11) / 2
    @origin.y = @height - @cellSize * 20 - @gap * 21

exports = module.exports = AsideEffectTetris
