AsideEffect = require './_aside_effect'
Util = require './_util'

# Credit: https://github.com/LeeYiyuan/tetrisai
class Piece
  constructor: (@cells) ->
    @dimension = @cells.length
    @row = 0
    @column = 0

  @fromIndex: (index) ->
    piece = switch index
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
    piece.row = 0
    piece.column = Math.floor((10 - piece.dimension) / 2) #Centralize
    piece

  clone: () =>
    cp = Util.cloneArray @cells
    piece = new Piece cp
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
    @iterator = -1

  next: ->
    ++@iterator
    @init() if @iterator >= @bag.length
    Piece.fromIndex @bag[@iterator]

class Grid
  constructor: (@rowSize, @columnSize) ->
    

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


exports = module.exports = AsideEffectTetris
