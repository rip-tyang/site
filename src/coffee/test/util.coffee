chai = require 'chai'
Util = require '../_util'

chai.should()
chai.use require('chai-things')

describe 'Util.arr', ->
  it 'should return a empty array when called without argument', ->
    t = Util.arr()
    t.should.be.a 'array'
    t.should.be.empty

  it 'should return a zero-filled array with first argument as length', ->
    randomLen = ~~(Math.random() * 10)
    t = Util.arr randomLen
    t.should.be.a 'array'
    t.should.have.length randomLen
    t.should.all.equals 0

  it 'should return a number filled with last argument', ->
    randomLen = ~~(Math.random() * 10)
    randomVal = ~~(Math.random() * 10)
    t = Util.arr randomLen, randomVal
    t.should.be.a 'array'
    t.should.have.length randomLen
    t.should.all.equals randomVal

  it 'should support map even with last argument equals `undefined`', ->
    randomLen = ~~(Math.random() * 10)
    randomVal = ~~(Math.random() * 10)
    t = Util.arr randomLen, undefined
    t.should.be.a 'array'
    t.should.have.length randomLen
    t.should.all.equals undefined
    tt = t.map () -> randomVal
    tt.should.all.equals randomVal

  it 'should return multidimensional array with the size specified by arguments excluding the last one ', ->
    randomL1 = ~~(Math.random() * 10)
    randomL2 = ~~(Math.random() * 10)
    randomVal = ~~(Math.random() * 10)
    t = Util.arr randomL1, randomL2, randomVal
    t.should.be.a 'array'
    t.should.have.length randomL1
    t.forEach (e) ->
      e.should.have.length randomL2
      e.should.all.equals randomVal

  it 'should accept last argument as a function and pass indexs of every dimension into it', ->
    randomL1 = ~~(Math.random() * 10)
    randomL2 = ~~(Math.random() * 10)
    func = (a, b) -> a + b

    t = Util.arr randomL1, randomL2, func
    t.should.be.a 'array'
    t.should.have.length randomL1
    t.forEach (e, i) ->
      e.should.have.length randomL2
      e.forEach (v, j) ->
        v.should.equals i + j

describe 'Util.shuffle', ->
  it 'should return `null` with invalid argument', ->
    t = [null, undefined, true, false, 0, 1, '', {}].map (e) -> Util.shuffle e
    t.should.all.equals null

  it 'should be ok with empty array', ->
    t = Util.shuffle []
    t.should.be.a 'array'
    t.should.be.empty

  it 'should not change elements', ->
    origArray = Util.arr ~~(Math.random() * 10), () -> ~~(Math.random() * 10)
    t = Util.shuffle origArray
    t.should.be.a 'array'
    t.should.have.length origArray.length
    t.should.all.to.be.oneOf origArray

describe 'Util.cloneArray', ->
  it 'should throw error when array contains obj', ->
    Util.cloneArray.bind(@, [{}]).should.throw Error

  it 'should deep clone array', ->
    args = Util.arr 1+~~(Math.random()*4), () -> ~~(Math.random()*8)
    args.push () -> ~~(Math.random()*100)
    tArr = Util.arr.apply(@, args)
    Util.cloneArray(tArr).should.eql tArr


describe 'Util.isSquareArray', ->
  it 'should return false with invalid argument', ->
    testArr = [null, undefined, true, false, 0, 1, '', {}]
    t = testArr.map (e) -> Util.isSquareArray e
    t.should.all.equals false

  it 'should indentify a square array', ->
    t1 = ~~(Math.random()*10)
    t2 = ~~(Math.random()*10)
    tArr = Util.arr t1, t2, 0

    t = Util.isSquareArray tArr
    t.should.equals t1 is t2

describe 'Util.rotateArrayClockwise', ->
  it 'should throw error with non-2d array', ->
    [t1, t2] = [~~(Math.random()*10), ~~(Math.random()*10)] while t1 is t2
    tArr = Util.arr t1, t2, 0
    Util.rotateArrayClockwise.bind(@, tArr).should.throw Error

  it 'should rotate an 2d array', ->
    tArr = [[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4]]
    rArr = [[1,1,1,1],[2,2,2,2],[3,3,3,3],[4,4,4,4]]
    Util.rotateArrayClockwise(tArr).should.eql rArr

describe 'Util.rotateArrayCounterClockwise', ->
  it 'should throw error with non-2d array', ->
    [t1, t2] = [~~(Math.random()*10), ~~(Math.random()*10)] while t1 is t2
    tArr = Util.arr t1, t2, 0
    Util.rotateArrayCounterClockwise.bind(@, tArr).should.throw Error

  it 'should rotate an 2d array', ->
    tArr = [[1,1,1,1],[2,2,2,2],[3,3,3,3],[4,4,4,4]]
    rArr = [[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4]]
    Util.rotateArrayCounterClockwise(tArr).should.eql rArr
