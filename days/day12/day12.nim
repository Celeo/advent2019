import sequtils, strformat, strutils

type
  Vector* = ref object
    x: int
    y: int
    z: int

  Moon* = ref object
    position: Vector
    velocity: Vector

proc newVector(x, y, z: int): Vector =
  Vector(x: x, y: y, z: z)

proc newMoon(x: int, y: int, z: int): Moon =
  Moon(
    position: newVector(x, y, z),
    velocity: newVector(0, 0, 0),
  )

proc `$`(v: Vector): string =
  &"<x={v.x:3}, y={v.y:3}, z={v.z:3}>"

proc `+=`(a: var Vector, b: Vector) =
  a = newVector(a.x + b.x, a.y + b.y, a.z + b.z)

proc `$`(m: Moon): string =
  &"pos={m.position}, vel={m.velocity}"

proc compare(a, b: int): int =
  if a < b: 1
  elif a > b: -1
  else: 0

proc applyGravity(moons: var seq[Moon]) =
  var pairs: seq[(int, int)] = @[]
  for i in 0..<4:
    for j in 0..<4:
      if (i, j) in pairs or (j, i) in pairs or i == j:
        continue
      pairs.add((i, j))
      let
        a = moons[i]
        b = moons[j]
      let
        deltaX = compare(a.position.x, b.position.x)
        deltaY = compare(a.position.y, b.position.y)
        deltaZ = compare(a.position.z, b.position.z)
      a.velocity.x += deltaX
      b.velocity.x -= deltaX
      a.velocity.y += deltaY
      b.velocity.y -= deltaY
      a.velocity.z += deltaZ
      b.velocity.z -= deltaZ

proc applyVelocity(moons: var seq[Moon]) =
  for m in moons:
    m.position += m.velocity

proc getTotalEnergy(moons: seq[Moon]): int =
  for m in moons:
    result += (m.position.x.abs() + m.position.y.abs() + m.position.z.abs()) *
               (m.velocity.x.abs() + m.velocity.y.abs() + m.velocity.z.abs())

when isMainModule:
  var moons = readFile("input.txt")
    .strip().splitLines()
    .mapIt(it[1..^2].split(", ").mapIt(it.split('=')[1].parseInt()))
    .mapIt(newMoon(it[0], it[1], it[2]))
  for i in 0..1000:
    echo(&"After {i} steps:")
    if i > 0:
      applyGravity(moons)
      applyVelocity(moons)
    for m in moons:
      echo(m)
    echo()
  echo("Part 1: ", getTotalEnergy(moons))
