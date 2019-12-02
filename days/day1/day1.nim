import math, sequtils, strutils

proc fuelCost(mass: int): int =
  ## Calculate the fuel requirements for the mass.
  floor(mass / 3).toInt() - 2

proc part1(masses: seq[int]): int =
  ## Calculate the fuel cost for all masses in the sequence and sum.
  masses
    .map(fuelCost)
    .foldl(a + b)

proc part2(masses: seq[int]): int =
  ## Calculate the fuel cost for all masses and the fuel therein, and sum.
  for mass in masses:
    var fuel = fuelCost(mass)
    while fuel > 0:
      result += fuel
      fuel = fuelCost(fuel)

when isMainModule:
  let masses = readFile("input.txt").strip().splitLines().map(parseInt)
  echo("Part 1: " & $part1(masses))
  echo("Part 2: " & $part2(masses))
