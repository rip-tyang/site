require '../stylus/main'
require './_polyfill'
domready = require 'domready'
LetterShuffle = require './_letter_shuffle'
ColorSwitch = require './_color_switch'
AsideEffectSnow = require './_aside_effect_snow'

domready ->
  colorSwitch = new ColorSwitch
    triggerEvent: 'click'
    triggerElem: document.getElementById 'logo'

  subtitleShuffle = new LetterShuffle
    targetElem: document.getElementsByTagName('h2')[0]
    triggerEvent: 'click'
    triggerElem: document.getElementById 'logo'

  asideEffect = new AsideEffectSnow document.getElementById 'asideBG'
  asideEffect.play()
