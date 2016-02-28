run = () ->
  f() for name, f of func

func = {}

# requestAnimationFrame() shim by Paul Irish
# http://paulirish.com/2011/requestanimationframe-for-smart-animating/
func.requestAnimationFrameForIE8 = () ->
  window.requestAnimationFrame = do ->
    window.requestAnimationFrame       ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame    ||
    window.oRequestAnimationFrame      ||
    window.msRequestAnimationFrame     ||
    (callback, elem) ->
      window.setTimeout(callback, 1000 / 60)

func.textContentForIE8 = () ->
  if Object.defineProperty and
  Object.getOwnPropertyDescriptor and
  Object.getOwnPropertyDescriptor(Element.prototype, 'textContent') and
  !Object.getOwnPropertyDescriptor(Element.prototype, 'textContent').get
    do ->
      innerText = Object.getOwnPropertyDescriptor Element.prototype,
        'innerText'
      Object.defineProperty Element.prototype, 'textContent',
        get: () ->
          return innerText.get.call(@)
        set: (s) ->
          return innerText.set.call(@, s)

func.eventListenerForIE8 = () ->
  return if window.addEventListener
  do (
    WindowPrototype = Window.prototype,
    DocumentPrototype = HTMLDocument.prototype,
    ElementPrototype = Element.prototype,
    addEventListener = 'addEventListener',
    removeEventListener = 'removeEventListener',
    dispatchEvent = 'dispatchEvent',
    registry = []) ->
      WindowPrototype[addEventListener] =
      DocumentPrototype[addEventListener] =
      ElementPrototype[addEventListener] = (type, listener) ->
        target = @
        eventFunc = (event) ->
          event.currentTarget = target
          event.preventDefault = -> event.returnValue = false
          event.stopPropagation = -> event.cancelBubble = true
          event.target = event.srcElement || target
          listener.call(target, event)

        registry.unshift [target, type, listener,eventFunc]

        this.attachEvent 'on' + type, registry[0][3]

        WindowPrototype[removeEventListener] =
        DocumentPrototype[removeEventListener] =
        ElementPrototype[removeEventListener] = (type, listener) ->
          for register in registry
            if register[0] is this &&
              register[1] is type &&
              register[2] is listener
                this.detachEvent 'on' + type, registry.splice(index, 1)[0][3]

        WindowPrototype[dispatchEvent] =
        DocumentPrototype[dispatchEvent] =
        ElementPrototype[dispatchEvent] = (eventObject) ->
          this.fireEvent 'on' + eventObject.type, eventObject

func.betterAnimation = () ->

  # Behaves the same as setInterval except uses requestAnimationFrame()
  # where possible for better performance
  # @param {function} fn The callback function
  # @param {int} delay The delay in milliseconds
  # modified so it fits more in CoffeeScrit
  window.requestInterval = (option) ->
    delay = option.delay
    fn = option.fn
    elem = option.elem || document
    handle = {}

    if not delay
      loopFunc = () ->
        res = fn.call()
        handle.value = window.requestAnimationFrame loopFunc, elem if res
      handle.value = window.requestAnimationFrame loopFunc, elem
    else
      if !window.requestAnimationFrame           &&
        !window.webkitRequestAnimationFrame      &&
        !(window.mozRequestAnimationFrame        &&
          window.mozCancelRequestAnimationFrame) &&
        !window.oRequestAnimationFrame           &&
        !window.msRequestAnimationFrame
          return window.setInterval(fn, delay)

      start = new Date().getTime()
      loopFunc = () ->
        current = new Date().getTime()
        delta = current - start

        if delta >= delay
          res = fn.call()
          start = new Date().getTime()
          handle.value = window.requestAnimationFrame loopFunc,elem if res
        else
          handle.value = window.requestAnimationFrame loopFunc,elem

      handle.value = window.requestAnimationFrame loopFunc,elem
    handle

  # Behaves the same as clearInterval
  # except uses cancelRequestAnimationFrame() where
  # possible for better performance
  # @param {int|object} fn The callback function
  # modified so it fits more in CoffeeScrit
  # window.clearRequestInterval = (handle) ->
  #   console.log 'clearing'
  #   if window.cancelAnimationFrame
  #     window.cancelAnimationFrame handle.value
  #   else if window.webkitCancelAnimationFrame
  #     window.webkitCancelAnimationFrame handle.value
  #   else if window.webkitCancelRequestAnimationFrame
  #     # Support for legacy API
  #     window.webkitCancelRequestAnimationFrame handle.value
  #   else if window.mozCancelRequestAnimationFrame
  #     window.mozCancelRequestAnimationFrame handle.value
  #   else if window.oCancelRequestAnimationFrame
  #     window.oCancelRequestAnimationFrame handle.value
  #   else if window.msCancelRequestAnimationFrame
  #     window.msCancelRequestAnimationFrame handle.value
  #   else clearInterval handle

  # Behaves the same as setTimeout
  # except uses requestAnimationFrame()
  # where possible for better performance
  # @param {function} fn The callback function
  # @param {int} delay The delay in milliseconds
  # modified so it fits more in CoffeeScrit

  # window.requestTimeout = (delay, fn) ->
  #   if !window.requestAnimationFrame           &&
  #     !window.webkitRequestAnimationFrame      &&
  #     !(window.mozRequestAnimationFrame        &&
  #       window.mozCancelRequestAnimationFrame) &&
  #     !window.oRequestAnimationFrame           &&
  #     !window.msRequestAnimationFrame
  #       return window.setTimeout(fn, delay)
  #
  #   start = new Date().getTime()
  #   handle = new Object()
  #
  #   loopFunc = () ->
  #     current = new Date().getTime()
  #     delta = current - start
  #
  #     if delta >= delay
  #       fn.call()
  #     else
  #       handle.value = window.requestAnimationFrame loopFunc
  #
  #   handle.value = requestAnimFrame loopFunc
  #   return handle

  # Behaves the same as clearTimeout except
  # uses cancelRequestAnimationFrame() where possible for better performance
  # @param {int|object} fn The callback function
  # modified so it fits more in CoffeeScrit

  # window.clearRequestTimeout = (handle) ->
  #   if window.cancelAnimationFrame
  #     window.cancelAnimationFrame handle.value
  #   else if window.webkitCancelAnimationFrame
  #     window.webkitCancelAnimationFrame handle.value
  #   else if window.webkitCancelRequestAnimationFrame
  #     # Support for legacy API
  #     window.webkitCancelRequestAnimationFrame handle.value
  #   else if window.mozCancelRequestAnimationFrame
  #     window.mozCancelRequestAnimationFrame handle.value
  #   else if window.oCancelRequestAnimationFrame
  #     window.oCancelRequestAnimationFrame handle.value
  #   else if window.msCancelRequestAnimationFrame
  #     window.msCancelRequestAnimationFrame handle.value
  #   else clearTimeout handle

exports = module.exports = run()
