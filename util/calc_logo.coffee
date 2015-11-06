# give a n, which denote a n * n square with value 0 - 1 respectively, the value is determined by the intersect area with a circle, which inner tangent by the n*n big square.

n = +process.argv[1]
throw new Error('enter a integer please') if !n || isNaN(parseFloat(n)) || !isFinite(n) || n isnt ~~n

# init
arr = []
for i in [0...n]
  arr[i] = new Array(n+1).join('1').split('').map(Number)

# circle equation
y = (x) -> Math.sqrt(1-x*x)

# intergral for circle equation
intY = (x) -> 0.5*(x*Math.sqrt(1-x*x) + Math.asin(x))

# R2 distance
dis = (p1, p2) ->
  Math.sqrt((p1[0] - p2[0])*(p1[0] - p2[0]) + (p1[1] - p2[1])*(p1[1] - p2[1]))

isIntersect = (coord) ->
  inOrOut = dis(coord[0], [0, 0]) > 1 && dis(coord[1], [0, 0]) > 1 &&
    dis(coord[2], [0, 0]) > 1 && dis(coord[3], [0, 0]) > 1 ||
    dis(coord[0], [0, 0]) < 1 && dis(coord[1], [0, 0]) < 1 &&
    dis(coord[2], [0, 0]) > 1 && dis(coord[3], [0, 0]) > 1
  !inOrOut


for cx in [0...n]
  for cy in [0...n]
    # upper left, upper right, lower left, lower right
    coord = [
      [-1+cy*(2/n), -1+cx*(2/n)],
      [-1+(cy+1)*(2/n), -1+cx*(2/n)],
      [-1+cy*(2/n), -1+(cx+1)*(2/n)],
      [-1+(cy+1)*(2/n), -1+(cx+1)*(2/n)]
    ]
    y(coord[1][0]) - y(coord[0][0]) if isIntersect
