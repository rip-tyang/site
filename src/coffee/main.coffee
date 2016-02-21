require '../stylus/main'
domready = require 'domready'
ColorSwitch = require './_color_switch'

domready () ->
  colorSwitch = new ColorSwitch(document.location,
    document.getElementById('logo'))
