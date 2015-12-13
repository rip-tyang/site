require '../stylus/main'
domready = require 'domready'
Sort = require './_sorting'

domready () ->
  window.addEventListener 'pivotColorChange', (e) ->
    subtitle.style.color = e.detail
  svg = document.getElementById 'sort'
  subtitle = document.getElementById 'subtitle'
  sort = new Sort(svg)
  sort.show()
