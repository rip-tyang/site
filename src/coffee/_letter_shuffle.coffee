Util = require './_util'

class LetterShuffle
  constructor: (option = {}) ->
    @step = option.step || 2
    @fps = option.fps || 24
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
    @endLoop() if @currentIndex >= @text.length
    if @currentStep > 0
      --@currentStep
    else
      ++@currentIndex
      @currentStep = ~~(Math.random()*@step)

    @elem.textContent = @text[0...@currentIndex] +
      @randomChar @text.length - @currentIndex

  play: () =>
    return if @loopId
    @currentIndex = 0
    @currentStep = 4*@step # let the first letter last longer
    @loopId = Util.loopFunc 1000/@fps, @tick

  endLoop: () =>
    if @loopId
      clearInterval @loopId
      @loopId = null

exports = module.exports = LetterShuffle
