require '../stylus/main'
require './_polyfill'
domready = require 'domready'
LetterShuffle = require './_letter_shuffle'
ColorSwitch = require './_color_switch'
RandomAsideEffect = require './_aside_effect_generator'
Banner = require './_banner'

domready ->
  colorSwitch = new ColorSwitch
    triggerEvent: 'click'
    triggerElem: document.getElementById('corner')

  subtitleShuffle = new LetterShuffle
    targetElem: document.getElementsByTagName('h2')[0]
    triggerEvent: 'click'
    triggerElem: document.getElementById('corner')

  asideEffect = new RandomAsideEffect
    canvas: document.getElementById 'asideBG'
    switch: document.getElementById('logo').children[0]
  asideEffect.play()

new Banner
