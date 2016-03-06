require '../stylus/main'
require './_polyfill'
domready = require 'domready'
LetterShuffle = require './_letter_shuffle'
ColorSwitch = require './_color_switch'
AsideEffectGenerator = require './_aside_effect_generator'
Banner = require './_banner'
HashtagManager = require './_hashtag_manager'

domready ->
  hashtagManager = new HashtagManager

  colorSwitch = new ColorSwitch
    triggerEvent: 'click'
    triggerElem: document.getElementById('corner')
    hash: hashtagManager

  subtitleShuffle = new LetterShuffle
    targetElem: document.getElementsByTagName('h2')[0]
    triggerEvent: 'click'
    triggerElem: document.getElementById('corner')

  effectGenerator = new AsideEffectGenerator
    canvas: document.getElementById 'asideBG'
    switch: document.getElementById('logo').children[0]
    nextTrigger: document.getElementById('logo').children[1]
    hash:hashtagManager

new Banner
