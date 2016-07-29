_ = require './_util'

class LetterShuffle
  Chars = [
    ",.?/\\(^)![]{}*&^%$#'\"|"
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    'abcdefghijklmnopqrstuvwxyz0123456789'
  ]

  TypeMap =
    symbol: 0
    upper: 1
    lower: 2

  constructor: (option = {}) ->
    # maximum time a letter will be shuffled
    @maxStep = option.maxStep || 8

    @type = option.type || 'lower'
    @elem = option.targetElem

    # split the target text by words
    # to keep the space not shuffled
    # which will yield better visual effect
    @text = @elem.textContent.slice 0

    @textArr = @text.split ' '
    @letters = Chars[TypeMap[@type]]
    @loopId

    if option.triggerEvent && option.triggerElem
      option.triggerElem.addEventListener option.triggerEvent, @play, false

  randomChar: (len = 1) =>
    return '' if len <= 0
    arr = _.arr len, => @letters[~~(Math.random() * @letters.length)]
    arr.join ''

  tick: =>
    return @endLoop() if @currentIndex >= @text.length

    if @currentStep > 0
      --@currentStep
    else
      ++@currentIndex
      if @currentIndex > @currentLen
        @currentLen += @textArr[++@currentArr].length + 1
      @currentStep = ~~(Math.random() * @maxStep)

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

    # from which letter until the last one will be randomized
    # this will increase to the length of the target text
    @currentIndex = 0

    # how many time left to move to the next letter
    # will also be randomized for every letter
    # let the first letter last longer
    @currentStep = 4 * @step

    @currentArr = 0
    @currentLen = @textArr[@currentArr].length
    @loopId = window.requestInterval
      fn: @tick
      elem: @elem

  endLoop: =>
    window.clearRequestInterval @loopId
    @loopId = null

exports = module.exports = LetterShuffle
