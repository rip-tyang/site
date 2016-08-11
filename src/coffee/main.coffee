require '../stylus/main'
require './_polyfill'
_ = require './_util'
domready = require 'domready'
LetterShuffle = require './_letter_shuffle'
ColorSwitch = require './_color_switch'
AsideEffectGenerator = require './_aside_effect_generator'
Banner = require './_banner'
HashtagManager = require './_hashtag_manager'

new Banner()

removeCornerShowClass = (e) ->
  @removeEventListener e.type, arguments.callee
  @classList.remove 'cornerShow'

domready ->
  $corner = document.getElementById 'corner'
  $canvas = document.getElementById 'asideBG'
  $logos = document.getElementById 'logo'
  hashtagManager = new HashtagManager()

  colorSwitchConfig =
    triggerEvent: 'click'
    triggerElem: $corner
    hash: hashtagManager
  colorSwitch = new ColorSwitch(colorSwitchConfig)

  subtitleShuffleConfig =
    targetElem: document.getElementsByTagName('h2')[0]
    triggerEvent: 'click'
    triggerElem: $corner
  subtitleShuffle = new LetterShuffle(subtitleShuffleConfig)

  effectGeneratorConfig =
    canvas: $canvas
    switch: $logos.children[0]
    nextTrigger: $logos.children[1]
    hash: hashtagManager
  effectGenerator = new AsideEffectGenerator(effectGeneratorConfig)

  # color switch corner init
  # show in the begining
  # hide when mouseout for the first time
  # show when hovering
  $corner.addEventListener 'mouseout', removeCornerShowClass, false
