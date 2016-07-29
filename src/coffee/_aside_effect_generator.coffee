AsideEffectSnow = require './_aside_effect_snow'
AsideEffectTetris = require './_aside_effect_tetris'
AsideEffectGameOfLife = require './_aside_effect_game_of_life'
AsideEffectRandomWalk = require './_aside_effect_random_walk.coffee'

class AsideEffectGenerator
  constructor: (option = {}) ->
    @effects = [
      AsideEffectSnow
      AsideEffectTetris
      AsideEffectGameOfLife
      AsideEffectRandomWalk
    ]
    @curr = null
    @instance = Array @effects.length
    @option = option

    @hashtagManager = option.hash
    throw Error 'No hashtag manager' unless @hashtagManager?
    @hashtagManager.onHashChange @hashChanged

    @nextTrigger = option.nextTrigger
    @nextTrigger.addEventListener 'click', @next, false if @nextTrigger?

    @hashChanged()

  hashChanged: =>
    idx = Number @hashtagManager.getHash('game')
    if 0 <= idx < @effects.length
      @idx = idx
    else
      @idx = ~~(Math.random() * @effects.length)
    @play()

  next: =>
    ++@idx
    @idx = if @idx >= @effects.length then 0 else @idx
    @hashtagManager.setHash 'game', @idx

  play: =>
    @curr?.pause().removeListener()
    @instance[@idx] = @instance[@idx] || new @effects[@idx](@option)
    @curr = @instance[@idx]
    @curr.reset().bindListener().play()

exports = module.exports = AsideEffectGenerator
