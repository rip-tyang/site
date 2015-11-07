svg = document.getElementById 'sort'
subtitle = document.getElementById 'subtitle'

window.addEventListener 'pivotColorChange', (e) ->
  subtitle.style.color = e.detail

sort = new Sort(svg)
sort.show()
