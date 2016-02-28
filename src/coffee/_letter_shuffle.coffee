Util = require './_util'

class LetterShuffle
  constructor: (option = {}) ->
    @step = option.step || 2
    @delay = option.delay || 0
    @type = option.type || 'lower'
    @elem = option.targetElem
    @text = @elem.textContent.slice 0
    @letters = Chars[TypeMap[@type]]
    @loopId

    if option.triggerEvent && option.triggerElem
      option.triggerElem.addEventListener option.triggerEvent, @play, false


  Chars = [
    ",.?/\\(^)![]{}*&^%$#'\""
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    'abcdefghijklmnopqrstuvwxyz0123456789'
  ]

  TypeMap =
    symbol: 0
    upper: 1
    lower: 2

  randomChar: (len = 1) =>
    return '' if len <= 0
    arr = Array.apply(null, Array(len))
    arr = arr.map (e) =>
      @letters[~~(Math.random()*@letters.length)]
    arr.join ''

  tick: () =>
    if @currentIndex >= @text.length
      return @endLoop()
    if @currentStep > 0
      --@currentStep
    else
      ++@currentIndex
      @currentStep = ~~(Math.random()*@step)

    @elem.textContent = @text[0...@currentIndex] +
      @randomChar @text.length - @currentIndex
    true

  play: () =>
    return if @loopId
    @currentIndex = 0
    @currentStep = 4*@step # let the first letter last longer
    @loopId = window.requestInterval
      fn: @tick
      elem: @elem

  endLoop: () =>
    @loopId = null
    false

exports = module.exports = LetterShuffle
