require '../stylus/404'
_ = require './_util'
domready = require 'domready'
Banner = require './_banner'

new Banner()

domready ->
  $canvas = document.getElementById 'canvas'
  
  _.loopFunc 100, ->
    elems = $canvas.getElementsByTagName('input')
    for elem in elems
        if Math.random() > 0.95
            elem.checked = !elem.checked
