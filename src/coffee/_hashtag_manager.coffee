qs = require 'querystring'

class HashtagManager
  constructor: ->
    @cb = []
    @obj = qs.parse document.location.hash.slice(1)
    window.addEventListener 'hashchange', @hashChanged, false

  hashChanged: =>
    @obj = qs.parse document.location.hash.slice(1)
    func(@obj) for func in @cb

  # will triger `hashchange` event
  setHash: (key, value) =>
    @obj[key] = value
    document.location.hash = "##{qs.stringify @obj}"

  delHash: (key) =>
    delete @obj.key

  getHash: (key) =>
    @obj[key]

  onHashChange: (func) =>
    @cb.push func if typeof func is 'function'

exports = module.exports = HashtagManager
