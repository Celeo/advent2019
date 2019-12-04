import hashes, math, sequtils, sets, strutils

type
  Point = object
    x: int
    y: int
    steps: int

proc newPoint(x, y, steps: int): Point =
  ## Create a new point object instance.
  Point(x: x, y: y, steps: steps)

proc `==`(a, b: Point): bool =
  ## Compare two points for equality.
  ##
  ## Note that the step count is NOT included in this test.
  a.x == b.x and a.y == b.y

proc hash(p: Point): Hash =
  ## Hash a point instance.
  ##
  ## Note that the step count is NOT included in the hash.
  !$(0 !& p.x !& p.y)

proc layWire(directions: seq[string]): HashSet[Point] =
  ## Return a seq of all the points the wire touches.
  var
    x = 0
    y = 0
    steps = 1
  for direction in directions:
    let
      d = direction[0]
      amount = direction.substr(1).parseInt()
    var
      xMod = 0
      xMult = 1
      yMod = 0
      yMult = 1
    case d:
      of 'R':
        xMod = amount
        xMult = -1
      of 'L':
        xMod = amount
      of 'U':
        yMod = amount
      of 'D':
        yMod = amount
        yMult = -1
      else:
        echo("Unknown direction: ", d)
        quit(1)
    while xMod > 0:
      x += xMult
      let p = newPoint(x, y, steps)
      if p notin result:
        result.incl(p)
      xMod.dec()
      steps.inc()
    while yMod > 0:
      y += yMult
      let p = newPoint(x, y, steps)
      if p notin result:
        result.incl(p)
      yMod.dec()
      steps.inc()

when isMainModule:
  let directions = readFile("input.txt").strip().splitLines().mapIt(it.split(","))
  let firstPoints = layWire(directions[0])
  let secondPoints = layWire(directions[1])
  var
    leastByDistance = 2 ^ 32
    leastBySteps = 2 ^ 23
  for point in firstPoints:
    if point in secondPoints:
      leastByDistance = min(leastByDistance, abs(point.x) + abs(point.y))
      let other = secondPoints.toSeq().filterIt(it == point)[0]
      leastBySteps = min(leastBySteps, point.steps + other.steps)
  echo("Part 1: ", leastByDistance)
  echo("Part 2: ", leastBySteps)
