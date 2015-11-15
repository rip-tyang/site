d3 = require 'd3'

class Sort
  # static methods and variables
  numCircles = 60
  colorPalette= d3.interpolateRgb('#E81D62', '#00BBD3')

  loopFunc = (delay, func) ->
    setInterval func, delay

  swap = (action, arr, i, j) ->
    return if i is j
    t = arr[i]
    arr[i] = arr[j]
    arr[j] = t
    action.push
      type: 'swap'
      m: i
      n: j

  pivot = (action, i) ->
    action.push
      type: 'pivot'
      val: i

  insertSort = (swap, pivot, arr) ->
    for i in [1...arr.length]
      t = -1
      for j in [i-1..0]
        if arr[i] > arr[j]
          t = j
          break
      for k in [i-1...j]
        swap arr, k, k+1
    for i in [0...arr.length]
      pivot i

  heapSort = (swap, pivot, arr) ->
    # build maximum heap
    maxify = (i, len) ->
      largest = i
      return if i*2 >= len

      if i*2 is len-1
        if arr[i*2] > arr[i]
          swap arr, i, i*2
        return
      if arr[i*2] > arr[largest]
        largest = i*2
      if arr[i*2+1] > arr[largest]
        largest = i*2+1

      return if largest is i
      swap arr, i, largest
      maxify largest, len

    for i in [~~(arr.length/2)..0]
      maxify i, arr.length

    for i in [arr.length-1...0]
      swap arr, 0, i
      pivot i
      maxify 0, i
    pivot 0


  selectionSort = (swap, pivot, arr) ->
    for i in [0...arr.length]
      min = Math.min()
      p = 0
      for j in [i...arr.length]
        if arr[j] < min
          min = arr[j]
          p = j
      swap arr, i, p
      pivot i

  bubbleSort = (swap, pivot, arr) ->
    for i in [arr.length-1..0]
      for j in [0...i]
        if arr[i] < arr[j]
          swap arr, i, j
      pivot i

  quickSort = (swap, pivot, arr, start, end) ->
    if start is end
      pivot start
      return
    i = start
    j = end
    for k in [i..j]
      if arr[k] < arr[j]
        swap arr, k, i
        ++i
    swap arr, j, i
    pivot i
    quickSort(swap, pivot, arr, start, i-1) if start < i
    quickSort(swap, pivot, arr, i+1, end) if i < end

  # Fisher-Yates (aka Knuth) Shuffle
  shuffle = (array) ->
    currentIndex = array.length
    # While there remain elements to shuffle...
    while 0 isnt currentIndex
      # Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex)
      --currentIndex
      # And swap it with the current element.
      tValue = array[currentIndex]
      array[currentIndex] = array[randomIndex]
      array[randomIndex] = tValue
    return array

  # event listener polyfill
  addEvent = (object, type, callback) ->
    return if object == null || typeof(object) == 'undefined'
    if object.addEventListener
      object.addEventListener type, callback, false
    else if object.attachEvent
      object.attachEvent "on" + type, callback
    else
      object["on"+type] = callback

  # fire a custom event
  # use to change the color of subtitle
  # TODO check browser compatibility
  fireColorChangeEvent = (color) ->
    event = new CustomEvent 'pivotColorChange', { 'detail': color }
    window.dispatchEvent event

  constructor: (@svg) ->
    addEvent window, 'resize', @svgOnResize
    @$svg = d3.select(@svg)
    @sortingFunc = []
    @actions = []
    @circles = []
    @actionLoopId = null
    @shuffledValue = shuffle([0..numCircles])
    @circles = @shuffledValue.map (e) ->
      {color: colorPalette(e/numCircles), id: e, pivot: false}
    @svgOnResize()

    @swap = swap.bind(null, @actions)
    @pivot = pivot.bind(null, @actions)

    # different sorting functions
    @sortingFunc.push insertSort.bind(@, @swap, @pivot, @shuffledValue)
    @sortingFunc.push heapSort.bind(@, @swap, @pivot, @shuffledValue)
    @sortingFunc.push selectionSort.bind(@, @swap, @pivot, @shuffledValue)
    @sortingFunc.push bubbleSort.bind(@, @swap, @pivot, @shuffledValue)
    @sortingFunc.push quickSort.bind(@,
        @swap,
        @pivot,
        @shuffledValue,
        0,
        @shuffledValue.length-1)

    # random sort
    @sortingFunc[~~(@sortingFunc.length*Math.random())]()

  svgOnResize: () =>
    rect = @svg.getBoundingClientRect()
    @svg.setAttribute 'width', rect.width
    @svg.setAttribute 'height', rect.height
    circlePosHeight = rect.height/2
    circlePosWidth = rect.width/(numCircles+2)
    @circles.forEach (e) ->
      e.cy = circlePosHeight
      e.cx = circlePosWidth
      e.w = circlePosWidth/3
      e.h = if e.pivot then circlePosWidth/3*4 else circlePosWidth/3
    @$svg.selectAll 'rect'
      .attr 'width', (v) -> v.w*2
      .attr 'height', (v) -> v.h*2
      .attr 'rx', (v) -> v.w
      .attr 'x', (v, i) -> v.cx*(i+1) - v.w
      .attr 'y', (v) -> v.cy - v.h
      .append 'title'
        .text (v) -> v.id

  show: () =>
    @$svg.selectAll 'rect'
      .data @circles, (v) -> v.id
      .enter()
      .append 'rect'
      .attr 'width', (v) -> v.w*2
      .attr 'height', (v) -> v.h*2
      .attr 'rx', (v) -> v.w
      .attr 'x', (v, i) -> v.cx*(i+1) - v.w
      .attr 'y', (v) -> v.cy - v.h
      .attr 'fill', (v) -> v.color
    @actionLoopId = loopFunc 60, @executeAction

  executeAction: () =>
    if 0 is @actions.length
      clearInterval @actionLoopId
      return
    action = @actions.shift()
    if action.type is 'swap'
      t = @circles[action.m]
      @circles[action.m] = @circles[action.n]
      @circles[action.n] = t
      @$svg.selectAll 'rect'
        .data @circles, (v) -> v.id
        .transition()
        .duration 300
        .ease 'easeInOutCubic'
        .attr 'x', (v, i) -> v.cx*(i+1) - v.w
    else if action.type is 'pivot'
      fireColorChangeEvent @circles[action.val].color
      @circles[action.val].h *= 4
      @circles[action.val].pivot = true
      @$svg.selectAll 'rect'
        .data @circles, (v) -> v.id
        .attr 'y', (v) -> v.cy - v.h
        .attr 'height', (v) -> v.h*2

exports = module.exports = Sort
