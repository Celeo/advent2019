import strutils, sequtils

proc valid(n: int, allowMoreThanTwo = true): bool =
  ## Determines if a number is valid.
  ##
  ## Note: don't need to check the length or boundies; that's handled by the input and loop.
  result = true
  let s = $n
  var
    last = ' '
    sameTrain = 0
    hasTrain = false
  for c in s:
    if c < last:
      return false
    if c == last:
      sameTrain.inc()
      if sameTrain == 2:
        hasTrain = true
      elif sameTrain > 2 and not allowMoreThanTwo:
        hasTrain = false
        sameTrain = 0
        last = ' '
    last = c
  if not hasTrain:
    return false

when isMainModule:
  doAssert(valid(112233) == true)
  doAssert(valid(123444) == true)
  doAssert(valid(111122) == true)
  doAssert(valid(112233, false) == true)
  doAssert(valid(123444, false) == false)
  doAssert(valid(111122, false) == true)

  let rangeParts = readFile("input.txt").strip().split("-")
  let
    rangeLow = rangeParts[0].parseInt()
    rangeHigh = rangeParts[1].parseInt()
  let validCountPart1 = (rangeLow..rangeHigh).toSeq().filterIt(valid(it)).len()
  echo("Part 1: " & $validCountPart1) # should be 1660
  let validCountPart2 = (rangeLow..rangeHigh).toSeq().filterIt(valid(it, false)).len()
  echo("Part 2: " & $validCountPart2) # FIXME not 280 or 1230
