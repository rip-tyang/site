Util = require './_util'
AsideEffectSnow = require './_aside_effect_snow'
AsideEffectTetris = require './_aside_effect_tetris'
AsideEffectGameOfLife = require './_aside_effect_game_of_life'

class AsideEffectGenerator
  constructor: (option = {})->
    @effects = [
      AsideEffectSnow
      AsideEffectTetris
      AsideEffectGameOfLife
    ]
    @idx = ~~(Math.random()*@effects.length)
    @instance = Util.arr @effects.length, null
    @option = option
    @nextTrigger = option.nextTrigger
    @nextTrigger.addEventListener 'click', @next, false if @nextTrigger?
    @curr
    @next()

  next: =>
    @curr.pause() if @curr?
    @idx = 0 if @idx is @effects.length
    @curr = @instance[@idx]
    @curr = @instance[@idx] = new @effects[@idx](@option) unless @curr?
    @curr.reset().play()
    ++@idx


exports = module.exports = AsideEffectGenerator
