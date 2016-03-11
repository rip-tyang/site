class Util
  @loopFunc: (delay, func) ->
    setInterval func, delay

  # construct multidimensional array with value or function
  # @para (size1, size2, size3, ..., value/func)
  # @func (index1, index2, index3, ...) -> value
  # example:
  # Util.arr() -> []
  # Util.arr(2) -> [0, 0]
  # Util.arr(2, 3) -> [3, 3]
  # Util.arr(2, 3, 0) -> [[0,0,0],[0,0,0]]
  # Util.arr(2, 3, function (a, b) { return a + b; }) -> [[0,1,2], [1,2,3]]
  @arr: (size, other..., v) ->
    # arr() -> []
    return [] unless size?

    # arr(2) -> [0, 0]
    return Array.apply(null, Array(size)).map(() -> 0) if arguments.length is 1

    # if last value is not a function, wrap it up
    _func = if typeof v isnt 'function' then () -> v else v

    array = (size, other..., v) ->
      return size() if arguments.length is 1
      return Array.apply(null, Array(size)).map (e, i) ->
        array.apply @, other.concat(v.bind(@, i))

    other.unshift size
    other.push _func
    array.apply @, other

  # Fisher-Yates (aka Knuth) Shuffle
  @shuffle: (array) ->
    return null unless Array.isArray array
    currentIndex = array.length
    # While there remain elements to shuffle...
    while 0 isnt currentIndex
      # Pick a remaining element...
      randomIndex = ~~(Math.random() * currentIndex)
      --currentIndex
      # And swap it with the current element.
      [array[currentIndex], array[randomIndex]] =
      [array[randomIndex], array[currentIndex]]
    array

  @cloneArray: (arr) =>
    if Array.isArray arr
      _arr = arr.slice 0
      return _arr = _arr.map @cloneArray
    else if typeof arr is 'object'
      throw Error 'Cannot clone nested array with object'
    else
      return arr

  # rotate a square 2d array in clockwise direction
  @isSquareArray: (arr) ->
    Array.isArray(arr) &&
    Array.isArray(arr[0]) &&
    arr.length is arr[0].length

  @rotateArrayClockwise: (arr) ->
    if not @isSquareArray arr
      throw Error 'Not a 2 dimensional array'

    size = arr.length
    center = ~~(size/2)

    for i in [0...center]
      for j in [i...size-i-1]
        [arr[i][j]
         arr[size-j-1][i]
         arr[size-i-1][size-j-1]
         arr[j][size-i-1] ] =
        [arr[size-j-1][i]
         arr[size-i-1][size-j-1]
         arr[j][size-i-1]
         arr[i][j] ]
    arr

  @rotateArrayCounterClockwise: (arr) ->
    if not @isSquareArray arr
      throw Error 'Not a 2 dimensional array'

    size = arr.length
    center = ~~(size/2)

    for i in [0...center]
      for j in [i...size-i-1]
        [arr[i][j]
         arr[j][size-i-1]
         arr[size-i-1][size-j-1]
         arr[size-j-1][i] ] =
        [arr[j][size-i-1]
         arr[size-i-1][size-j-1]
         arr[size-j-1][i]
         arr[i][j] ]
    arr

exports = module.exports = Util
