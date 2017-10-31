_ = require './_util'
AsideEffect = require './_aside_effect'

class Point
  # coffeelint: disable=no_empty_functions
  constructor: (@x, @y) ->
  # coffeelint: enable=no_empty_functions

  print: =>
    "Point(#{@x}, #{@y})"

  equal: (p) =>
    p.x == @x && p.y == @y

  left: =>
    new Point(@x, @y - 1)

  right: =>
    new Point(@x, @y + 1)

  up: =>
    new Point(@x - 1, @y)

  down: =>
    new Point(@x + 1, @y)

class Edge
  constructor: (@from, @to) ->
    @weight = Math.random()

class Grid
  constructor: (options = {}) ->
    @row = options.row || 30
    @column = options.column || 10
    @points = _.arr @row, @column, (i, j) -> new Point(i, j)
    @mst = _.arr @row, @column, -> 0
    # horizontal edges
    @hEdges = _.arr(@row,
                    @column - 1,
                    (i, j) => new Edge(@points[i][j], @points[i][j + 1]))
    # vertical edges
    @vEdges = _.arr(@row - 1,
                    @column,
                    (i, j) => new Edge(@points[i][j], @points[i + 1][j]))
    @prim()

  getEdge: (p1, p2) =>
    if p1.x == p2.x
      if p1.y < p2.y then @hEdges[p1.x][p1.y] else @hEdges[p2.x][p2.y]
    else
      if p1.x < p2.x then @vEdges[p1.x][p1.y] else @vEdges[p2.x][p2.y]

  getAdjacent: (p) =>
    res = []
    if p.x > 0
      res.push @points[p.x - 1][p.y]
    if p.x < @row - 1
      res.push @points[p.x + 1][p.y]
    if p.y > 0
      res.push @points[p.x][p.y - 1]
    if p.y < @column - 1
      res.push @points[p.x][p.y + 1]
    res

  # applying prim method to find minimal spanning tree
  prim: =>
    cValue = _.arr @row, @column, -> 1
    cEdge = _.arr @row, @column, -> null
    vertices = new Set()
    @points.forEach (row) ->
      row.forEach (p) ->
        vertices.add p

    # init
    initP = @points[~~(Math.random() * @row)][~~(Math.random() * @column)]
    vertices.delete initP
    adjacents = @getAdjacent(initP)
    adjacents.forEach (p) =>
      edge = @getEdge(initP, p)
      if edge.weight < cValue[p.x][p.y]
        cValue[p.x][p.y] = edge.weight
        cEdge[p.x][p.y] = edge

    while vertices.size > 0
      minC = 1
      p = null
      vertices.forEach (e) ->
        v = cValue[e.x][e.y]
        if v < minC
          minC = v
          p = e
      vertices.delete p
      adjacents = @getAdjacent(p)
      adjacents.forEach (ap) =>
        edge = @getEdge(ap, p)
        if edge.weight < cValue[ap.x][ap.y]
          cValue[ap.x][ap.y] = edge.weight
          cEdge[ap.x][ap.y] = edge
      if cEdge[p.x][p.y]?
        tEdge = cEdge[p.x][p.y]
        if tEdge.from.x == tEdge.to.x
          if tEdge.from.y < tEdge.to.y
            @mst[tEdge.from.x][tEdge.from.y] |= 0x2
            @mst[tEdge.to.x][tEdge.to.y] |= 0x8
          else
            @mst[tEdge.from.x][tEdge.from.y] |= 0x8
            @mst[tEdge.to.x][tEdge.to.y] |= 0x2
        else
          if tEdge.from.x < tEdge.to.x
            @mst[tEdge.from.x][tEdge.from.y] |= 0x4
            @mst[tEdge.to.x][tEdge.to.y] |= 0x1
          else
            @mst[tEdge.from.x][tEdge.from.y] |= 0x1
            @mst[tEdge.to.x][tEdge.to.y] |= 0x4
    @mst

  makePath: =>
    start = new Point(@row, 0)
    path = _.arr @row * 2, @column * 2, -> -1
    pIndex = []
    next = start
    idx = 0
    loop
      path[next.x][next.y] = idx++
      pIndex.push next
      flag = @mst[~~(next.x / 2)][~~(next.y / 2)]
      if next.x % 2 && next.y % 2
        if flag & 0x4
          next = next.down()
        else
          next = next.left()
      else if next.x % 2
        if flag & 0x8
          next = next.left()
        else
          next = next.up()
      else if next.y % 2
        if flag & 0x2
          next = next.right()
        else
          next = next.down()
      else
        if flag & 0x1
          next = next.up()
        else
          next = next.right()
      break if next.equal start
    [path, pIndex]


class Snake
  D =
   up: 0x1
   right: 0x2
   down: 0x4
   left: 0x8

  constructor: (@path, @pArr) ->
    @r = @path.length
    @c = @path[0].length
    halfR = @r / 2
    @total = @r * @c
    @grid = _.arr @r, @c, -> true
    @pC = @total
    @pI = 0
    @arr = [new Point(halfR, 0)
            new Point(halfR, -3)
            new Point(halfR, -2)
            new Point(halfR, -1)]
    @directions = [0x2, 0x2, 0x2, 0x2]
    @grid[halfR][0] = false
    @len = 4
    @head = 0

  dCompose: (d1, d2) ->
    if d1 == d2 then d1 else ((d1 << 4) | d2) & 0xFF

  firstD: (d) ->
    (d >> 4) & 0xF

  secondD: (d) ->
    d & 0xF

  updatePathTo: (pU) =>
    while !pU.equal(@pArr[@pI])
      p = @pArr[@pI]
      @path[p.x][p.y] = @pC++
      @pI = (@pI + 1) % @total

  turn: (direction, grow) =>
    # if !direction?
    #   debugger
    ph = @arr[@head]
    if grow
      h = ph[direction]()
      @arr.splice(@head + 1, 0, h)
      @directions.splice(@head + 1, 0, D[direction])
      @directions[@head] = @dCompose(@directions[@head], D[direction])
      @grid[h.x][h.y] = false
      @head++
      @len++
    else
      @directions[@head] = @dCompose(@directions[@head], D[direction])
      @head = (@head + 1) % @len

      h = ph[direction]()
      t = @arr[@head]
      @grid[h.x][h.y] = false
      if @grid[t.x][t.y]?
        @grid[t.x][t.y] = true
      @arr[@head] = h

      secondLast = (@head + 1) % @len
      if @firstD(@directions[secondLast]) == @directions[@head]
        @directions[secondLast] = @secondD(@directions[secondLast])
      @directions[@head] = D[direction]
    @updatePathTo(@arr[@head])
    @

  adjacents: =>
    res = []
    ph = @arr[@head]
    if ph.x > 0
      res.push ['up', ph.up()]
    if ph.x < @r - 1
      res.push ['down', ph.down()]
    if ph.y > 0
      res.push ['left', ph.left()]
    if ph.y < @c - 1
      res.push ['right', ph.right()]
    res

  next: (food) =>
    ph = @arr[@head]
    pt = @arr[(@head + 1) % @len]
    fIndex = @path[food.x][food.y]
    cIndex = @path[ph.x][ph.y]
    tIndex = @path[pt.x][pt.y] || Infinity
    direction = null
    nIndex = (cIndex + 1) % @total
    ads = @adjacents()
    destiny = false
    ads.forEach (ad) =>
      [d, p] = ad
      if Math.random() < .2 then destiny = true
      if direction? && destiny then return false
      if fIndex >= @path[p.x][p.y] >= nIndex &&
         @path[p.x][p.y] < tIndex
        nIndex = @path[p.x][p.y]
        direction = d
    @turn direction, nIndex == fIndex
    nIndex == fIndex

  draw: (ctx, l, t, s, r) =>
    @directions.forEach (d, i) =>
      p = @arr[i]
      ctx.save()
      ctx.translate(l + s * (p.y + .5), t + s * (p.x + .5))
      if d & (d - 1)
        if d == ((0x1 << 4) | 0x2) ||
           d == ((0x8 << 4) | 0x4)
          ctx.rotate(.5 * Math.PI)
        else if d == ((0x1 << 4) | 0x8) ||
                d == ((0x2 << 4) | 0x4)
          ctx.rotate(Math.PI)
        else if d == ((0x2 << 4) | 0x1) ||
                d == ((0x4 << 4) | 0x8)
          ctx.rotate((-.5) * Math.PI)
        ctx.beginPath()
        ctx.moveTo(s * (-r) / 2, s * (-.5))
        ctx.lineTo(s * r / 2, s * (-.5))
        ctx.lineTo(s * r / 2, s * (-r) / 2)
        ctx.lineTo(s * .5, s * (-r) / 2)
        ctx.lineTo(s * .5, s * r / 2)
        ctx.lineTo(s * (-r) / 2, s * r / 2)
        ctx.closePath()
        ctx.fill()
      else
        if d == 0x1 || d == 0x4
          ctx.rotate(.5 * Math.PI)
        ctx.fillRect(s * (-.5), s * (-r) / 2, s, s * r)
      ctx.restore()

class AsideEffectSnake extends AsideEffect
  @name: 'snake'
  constructor: ->
    super
    @width = @canvas.width
    @height = @canvas.height
    @ratio = .5
    @colSize = 10
    @rowSize = 24
    grid = new Grid({
      row: @rowSize / 2
      column: @colSize / 2
    })
    [@path, @pI] = grid.makePath()
    @snake = new Snake(@path, @pI)
    @food = @newFood()
    # @delay = 200
    @onResize()

  reset: =>
    super
    @ctx.fillStyle = 'rgba(255,255,255,0.5)'
    @

  tick: =>
    super

    # move snake
    if @snake.next(@food)
      @food = @newFood()

    @ctx.clearRect 0, 0, @canvas.width, @canvas.height

    # @path.forEach (row, i) =>
    #   row.forEach (cell, j) =>
    #     @ctx.fillText(cell, @leftPad + @cellSize * (j + .5), @topPad + @cellSize * (i + .5))

    @snake.draw @ctx, @leftPad, @topPad, @cellSize, @ratio

    if !@food?
      @pause()
      return

    # draw food
    @ctx.beginPath()
    @ctx.arc(@leftPad + (@food.y + .5) * @cellSize,
             @topPad + (@food.x + .5) * @cellSize,
             @ratio * @cellSize * .5,
             0,
             2 * Math.PI)
    @ctx.closePath()
    @ctx.fill()

  newFood: =>
    count = @colSize * @rowSize - @snake.len
    if count == 0 then return null
    for i in [0...@rowSize]
      for j in [0...@colSize]
        if @snake.grid[i][j] && Math.random() < (1 / count--)
          return new Point(i, j)

  onResize: =>
    super
    @width = @canvas.width
    @height = @canvas.height
    @cellSize = Math.min(~~(@width / @colSize), ~~(@height / @rowSize))
    @leftPad = ~~((@width - @cellSize * @colSize) / 2)
    @topPad = ~~((@height - @cellSize * @rowSize) / 2)

module.exports = AsideEffectSnake
