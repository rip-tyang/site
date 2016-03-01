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

class RandomPieceGenerator
  constructor: ->
    @bag = [0...7]
    @init()

  init: ->
    Util.shuffle @bag
    @iterator = 0
    @

  next: ->
    @init() if @iterator is @bag.length-1
    Piece.fromIndex @bag[@iterator++]

class Grid
  constructor: (@rowSize, @colSize, _cells) ->
    @cells = Util.arr @rowSize, @colSize,
      (if _cells? then (i, j) -> _cells[i][j] else 0)

  clone: =>
    new Grid @rowSize, @colSize, @cells

  isLine: (row) =>
    for i in [0...@colSize]
      return false if @cells[row][i] is 0
    return true

  isEmptyRow: (row) =>
    for i in [0...@colSize]
      return false if @cells[row][i] is 1
    return true

  clearLines: =>
    dis = 0
    for i in [@rowSize-1..0]
      if @isLine(i)
        ++dis
        for j in [0...@colSize]
          @cell[i][j] = 0
      else if dis > 0
        for j in [0...@colSize]
          @cells[i+dis][j] = @cell[i][j]
          @cell[i][j] = 0
    distance

class AsideEffectTetris extends AsideEffect
  constructor: ->
    super
    @cellSize
    @width
    @height
    @onResize()

  onResize: () =>
    super
    @width = @canvas.width
    @height = @canvas.height

new Grid(3, 2)
exports = module.exports = AsideEffectTetris
