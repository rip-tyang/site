AsideEffectSnow = require './_aside_effect_snow'
AsideEffectTetris = require './_aside_effect_tetris'
AsideEffectGameOfLife = require './_aside_effect_game_of_life'
AsideEffectRandomWalk = require './_aside_effect_random_walk'
# comment for not cool
# AsideEffectPerlin = require './_aside_effect_perlin'

class AsideEffectGenerator
  constructor: (option = {}) ->
    @effects = [
      AsideEffectSnow
      AsideEffectTetris
      AsideEffectGameOfLife
      AsideEffectRandomWalk
      # comment for not cool
      # AsideEffectPerlin
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
    @idx %= @effects.length
    @hashtagManager.setHash 'game', @idx

  play: =>
    @curr?.pause().removeListener()
    @instance[@idx] = @instance[@idx] || new @effects[@idx](@option)
    @curr = @instance[@idx]
    @curr.reset().bindListener().play()

exports = module.exports = AsideEffectGenerator
