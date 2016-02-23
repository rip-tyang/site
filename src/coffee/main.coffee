require '../stylus/main'
require './_polyfill'
domready = require 'domready'
LetterShuffle = require './_letter_shuffle'
ColorSwitch = require './_color_switch'

domready () ->
  colorSwitch = new ColorSwitch document.location,
    document.getElementById 'logo'
  s = new LetterShuffle document.getElementsByTagName('h2')[0],
    triggerEvent: 'click'
    triggerElem: document.getElementById 'logo'
