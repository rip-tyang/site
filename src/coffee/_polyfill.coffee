run = () ->
  textContentForIE8()

textContentForIE8 = () ->
  if Object.defineProperty and
  Object.getOwnPropertyDescriptor and
  Object.getOwnPropertyDescriptor(Element.prototype, 'textContent') and
  !Object.getOwnPropertyDescriptor(Element.prototype, 'textContent').get
    do ->
      innerText = Object.getOwnPropertyDescriptor Element.prototype,
        'innerText'
      Object.defineProperty(Element.prototype, 'textContent',
        get: () ->
          return innerText.get.call(@)
        set: (s) ->
          return innerText.set.call(@, s)
      )

exports = module.exports = run()
