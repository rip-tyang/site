class Sort
  # static methods and variables
  numCircles = 60
  colorPalette= d3.interpolateRgb('#E81D62', '#00BBD3')

  loopFunc = (delay, func) ->
    setInterval func, delay

  bubbleSort = (arr, actionArray) ->
    for i in [arr.length-1..0]
      for j in [0...i]
        if arr[i] < arr[j]
          t = arr[i]
          arr[i] = arr[j]
          arr[j] = t
          actionArray.push
            type: 'swap'
            m: i
            n: j
      actionArray.push
        type: 'pivot'
        val: i

  quickSort = (arr, actionArray, start, end) ->
    if start is end
      actionArray.push
        type: 'pivot'
        val: start
      return
    i = start
    j = end
    for k in [i..j]
      if arr[k] < arr[j]
        t = arr[k]
        arr[k] = arr[i]
        arr[i] = t
        if k isnt i
          actionArray.push
            type: 'swap'
            m: k
            n: i
        ++i
    t = arr[j]
    arr[j] = arr[i]
    arr[i] = t
    if i isnt j
      actionArray.push
        type: 'swap'
        m: j
        n: i
    actionArray.push
      type: 'pivot'
      val: i
    quickSort(arr, actionArray, start, i-1) if start < i
    quickSort(arr, actionArray, i+1, end) if i < end

  # Fisher-Yates (aka Knuth) Shuffle
  shuffle = (array) ->
    currentIndex = array.length
    # While there remain elements to shuffle...
    while 0 isnt currentIndex
      # Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex)
      currentIndex -= 1
      # And swap it with the current element.
      temporaryValue = array[currentIndex]
      array[currentIndex] = array[randomIndex]
      array[randomIndex] = temporaryValue
    return array

  addEvent = (object, type, callback) ->
    return if object == null || typeof(object) == 'undefined'
    if object.addEventListener
      object.addEventListener type, callback, false
    else if object.attachEvent
      object.attachEvent "on" + type, callback
    else
      object["on"+type] = callback

  fireColorChangeEvent = (color) ->
    event = new CustomEvent 'pivotColorChange', { 'detail': color }
    window.dispatchEvent event

  constructor: (@svg) ->
    addEvent window, 'resize', @svgOnResize
    @$svg = d3.select(svg)
    @circles = []
    @actions = []
    @actionLoopId = null
    @shuffledValue = shuffle([0..numCircles])
    @circles = @shuffledValue.map (e) ->
      {color: colorPalette(e/numCircles), id: e}
    @svgOnResize()
    # bubbleSort(@shuffledValue, @actions)
    quickSort(@shuffledValue, @actions, 0, @shuffledValue.length-1)

  svgOnResize: () =>
    rect = @svg.getBoundingClientRect()
    @svg.setAttribute 'width', rect.width
    @svg.setAttribute 'height', rect.height
    circlePosHeight = rect.height/2
    circlePosWidth = rect.width/(numCircles+2)
    @circles.forEach (e, i) ->
      e.cy = circlePosHeight
      e.cx = circlePosWidth
      e.w = circlePosWidth/3
      e.h = circlePosWidth/3
    @$svg.selectAll 'rect'
      .attr 'width', (v) -> v.w*2
      .attr 'height', (v) -> v.h*2
      .attr 'rx', (v) -> v.r
      .attr 'x', (v, i) -> v.cx*(i+1) - v.w
      .attr 'y', (v) -> v.cy - v.h

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
    @actionLoopId = loopFunc 100, @executeAction

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
        .duration 400
        .ease 'easeInOutCubic'
        .attr 'x', (v, i) -> v.cx*(i+1) - v.w
    else if action.type is 'pivot'
      fireColorChangeEvent @circles[action.val].color
      @circles[action.val].h *= 8
      @$svg.selectAll 'rect'
        .data @circles, (v) -> v.id
        .attr 'y', (v) -> v.cy - v.h
        .attr 'height', (v) -> v.h*2
