run = () ->
  f() for name, f of func

func = {}

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

exports = module.exports = run()
