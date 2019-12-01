import math, sequtils, strutils, sugar

proc part1(masses: seq[string]): int =
  foldl(map(masses, (m) => math.floor(m.parseInt() / 3).toInt() - 2), a + b)

when isMainModule:
  let masses = readFile("input.txt").strip().splitLines()
  echo("Total cost of fuel: " & $part1(masses))
