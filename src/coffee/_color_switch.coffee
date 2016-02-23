class ColorSwitch
  constructor: (option = {}) ->
    @mainColor
    @secondaryColor
    @location = document.location
    @sheet = document.createElement 'style'
    @sheet.id = 'colorSheet'
    @checkHashTag()
    @bindHashTag()
    document.head.appendChild @sheet
    if option.triggerEvent && option.triggerElem
      option.triggerElem.addEventListener option.triggerEvent,
        @randomColor,
        false

  # static methods
  red = (color6Digit) ->
    return parseInt(color6Digit[0...2], 16)

  green = (color6Digit) ->
    return parseInt(color6Digit[2...4], 16)

  blue = (color6Digit) ->
    return parseInt(color6Digit[4...6], 16)

  bindHashTag: () =>
    window.addEventListener 'hashchange', @checkHashTag, false

  checkHashTag: () =>
    urlColor = @location.hash.split('#color=')[1]
    if urlColor
      @parseColor urlColor
      @updateSheet()

  parseColor: (color) =>
    if color and color.length
      wColor = color
      if wColor.length is 3
        wcolor = wColor.split('').map((e) -> e+e).join('')
      @mainColor = "##{wColor}"
      @secondaryColor =
        "rgba(#{red(wColor)},#{green(wColor)},#{blue(wColor)},0.8)"

  randomColor: () =>
    colorString = (~~(Math.random()*0xFFFFFF)).toString(16)
    if colorString.length < 6
      colorString = Array(7 - colorString.length).join('0') + colorString
    @parseColor colorString
    @updateSheet()
    @location.hash = "#color=#{colorString}"

  updateSheet: () =>
    @sheet.innerHTML = """
      *::selection {
        color: #{@mainColor} !important;
      }
      .color {
        color: #{@mainColor} !important;
      }
      .color::before,
      .color::after {
        background-color: #{@mainColor} !important;
      }
      .colorBg {
        background-color: #{@mainColor} !important;
      }
      .colorLight {
        color: #{@secondaryColor} !important;
      }
      .colorLight::before,
      .colorLight::after {
        background-color: #{@secondaryColor} !important;
      }
      .colorHover:hover {
        color: #{@mainColor} !important;
      }
      .colorScroll::-webkit-scrollbar {
        background-color: #{@secondaryColor} !important;
      }
    """
exports = module.exports = ColorSwitch
