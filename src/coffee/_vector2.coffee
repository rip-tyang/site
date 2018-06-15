class Vector2
  constructor: (@x, @y) ->
    @magnitude = Math.sqrt(@x * @x + @y * @y)

  add: (v) =>
    new Vector2(@x + v.x, @y + v.y)

  minus: (v) =>
    new Vector2(@x - v.x, @y - v.y)

  dot: (v) =>
    @x * v.x + @y * v.y

  times: (a) =>
    new Vector2(@x * a, @y * a)

  div: (a) =>
    new Vector2(@x / a, @y / a)

   std: =>
     @div(@magnitude)

module.exports = Vector2
