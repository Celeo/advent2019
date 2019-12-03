import math, sequtils, sets, strutils, sugar

proc distanceTo(a: (int, int)): int =
  ## Calculate the distance between the point and the origin.
  abs(a[0]) + abs(a[1])

proc layWire(directions: seq[string]): HashSet[(int, int)] =
  ## Return a seq of all the points the wire touches.
  var x = 0
  var y = 0
  for direction in directions:
    let d = direction[0]
    let amount = direction.substr(1).parseInt()
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
      result.incl((x, y))
      xMod.dec()
    while yMod > 0:
      y += yMult
      result.incl((x, y))
      yMod.dec()

when isMainModule:
  let directions = readFile("input.txt").strip().splitLines().map(line => line.split(","))
  let firstPoints = layWire(directions[0])
  let secondPoints = layWire(directions[1])
  var least = 2 ^ 32
  for point in firstPoints:
    if point in secondPoints:
      let distance = distanceTo(point)
      least = min(least, distance)
  echo(least)
