Util = require './_util'

class LetterShuffle
  constructor: (option = {}) ->
    @step = option.step || 2
    @delay = option.delay || 0
    @type = option.type || 'lower'
    @elem = option.targetElem
    @text = @elem.textContent.slice 0
    @textArr = @text.split ' '
    @letters = Chars[TypeMap[@type]]
    @loopId

    if option.triggerEvent && option.triggerElem
      option.triggerElem.addEventListener option.triggerEvent, @play, false


  Chars = [
    ",.?/\\(^)![]{}*&^%$#'\"|"
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    'abcdefghijklmnopqrstuvwxyz0123456789'
    # "fijkl,.?/\\(^)![]{}*&^%$#'\"|"
  ]

  TypeMap =
    symbol: 0
    upper: 1
    lower: 2

  randomChar: (len = 1) =>
    return '' if len <= 0
    arr = Array.apply null, Array(len)
    arr = arr.map (e) =>
      @letters[~~(Math.random() * @letters.length)]
    arr.join ''

  tick: =>
    if @currentIndex >= @text.length
      return @endLoop()
    if @currentStep > 0
      --@currentStep
    else
      ++@currentIndex
      if @currentIndex > @currentLen
        @currentLen += @textArr[++@currentArr].length + 1
      @currentStep = ~~(Math.random() * @step)
    texts = @textArr.map (e, i) =>
      if i < @currentArr
        return e
      else if i is @currentArr
        return e[0...e.length - (@currentLen - @currentIndex)] +
          @randomChar(@currentLen - @currentIndex)
      else return @randomChar e.length
    @elem.textContent = texts.join ' '

  play: =>
    return if @loopId
    @currentIndex = 0
    @currentStep = 4 * @step # let the first letter last longer
    @currentArr = 0
    @currentLen = @textArr[@currentArr].length
    @loopId = window.requestInterval
      fn: @tick
      elem: @elem

  endLoop: =>
    window.clearRequestInterval @loopId
    @loopId = null

exports = module.exports = LetterShuffle
