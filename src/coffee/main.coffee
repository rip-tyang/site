require '../stylus/main'
domready = require 'domready'

red = (color) ->
  return parseInt(color[0...2], 16)

green = (color) ->
  return parseInt(color[2...4], 16)

blue = (color) ->
  return parseInt(color[4...6], 16)

refreshWithNewColor = () ->
  newColor = ~~(Math.random()*0xFFFFFF)
  window.location.search = "?color=#{newColor.toString(16)}"
domready () ->
  document.getElementById('refresh').addEventListener(
    'click', refreshWithNewColor, false)

  color = location.search.split('?color=')[1]
  if color && color.length
    mainColor = "##{color}"
    if color.length is 6
      secondaryColor = "rgba(#{red(color)},#{green(color)},#{blue(color)},0.8)"
    else return

    sheet = document.createElement 'style'
    sheet.innerHTML = """
      .color {
        color: #{mainColor} !important;
      }
      .color::before,
      .color::after {
        background-color: #{mainColor} !important;
      }
      .colorBg {
        background-color: #{mainColor} !important;
      }
      .colorLight {
        color: #{secondaryColor} !important;
      }
      .colorLight::before,
      .colorLight::after {
        background-color: #{secondaryColor} !important;
      }
      .colorHover:hover {
        color: #{mainColor} !important;
      }
      .colorScroll::-webkit-scrollbar {
        background-color: #{secondaryColor} !important;
      }
    """
    document.head.appendChild sheet
    console.log sheet
