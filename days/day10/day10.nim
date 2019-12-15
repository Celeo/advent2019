import math, sets, strutils

proc selectMonitoringPoint(points: seq[(int, int)]): (int, (int, int)) =
  var
    maxAsteroids = 0
    bestPoint = (0, 0)
  for (x, y) in points:
    var slopes = initHashSet[(int, int)]()
    for (x2, y2) in points:
      if x != x2 or y != y2:
        var
          dx = x2 - x
          dy = y2 - y
        dx = (dx / gcd(dx, dy)).floor().toInt()
        dy = (dy / gcd(dx, dy)).floor().toInt()
        slopes.incl((dx, dy))
    if slopes.len() > maxAsteroids:
      maxAsteroids = slopes.len()
      bestPoint = (x, y)
  (maxAsteroids, bestPoint)

when isMainModule:
  let data = readFile("input.txt").strip().splitLines()
  var points: seq[(int, int)] = @[]
  for x in 0..<data[0].len():
    for y in 0..<data.len():
      if data[x][y] == '#':
        points.add((y, x))

  echo(selectMonitoringPoint(points))
