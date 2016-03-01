AsideEffectSnow = require './_aside_effect_snow'
# AsideEffectTetris = require './_aside_effect_tetris'

effects = [
  AsideEffectSnow
]

exports = module.exports = effects[~~(Math.random()*effects.length)]
