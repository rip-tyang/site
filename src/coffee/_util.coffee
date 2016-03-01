class Util
  @loopFunc: (delay, func) ->
    setInterval func, delay

  # Fisher-Yates (aka Knuth) Shuffle
  @shuffle: (array) ->
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

  @cloneArray: (arr) ->
    if Array.isArray arr
      _arr = arr.slice 0
      for i in [0..._arr.length]
        _arr[i] = @cloneArray _arr[i]
      _arr
    else if typeof arr is 'object'
      throw Error 'Cannot clone nested array with object'
    else
      arr

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
