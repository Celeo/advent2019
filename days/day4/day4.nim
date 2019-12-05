import strutils, sequtils

proc valid(n: int, allowMoreThanTwo = true): bool =
  ## Determines if the number is valid.
  result = true
  let s = $n
  if s.len() != 6:
    return false
  if s[0] > s[1] or s[1] > s[2] or s[2] > s[3] or s[3] > s[4] or s[4] > s[5]:
    return false
  var found = false
  for i in 0..9:
    if allowMoreThanTwo:
      if ($i & $i) in s:
        found = true
        break
    else:
      if ($i & $i) in s and ($i & $i & $i) notin s:
        found = true
        break
  if not found:
    return false

when isMainModule:
  let rangeParts = readFile("input.txt").strip().split("-")
  let
    rangeLow = rangeParts[0].parseInt()
    rangeHigh = rangeParts[1].parseInt()
  let validCountPart1 = (rangeLow..rangeHigh).toSeq().filterIt(valid(it)).len()
  echo("Part 1: " & $validCountPart1)
  let validCountPart2 = (rangeLow..rangeHigh).toSeq().filterIt(valid(it, false)).len()
  echo("Part 2: " & $validCountPart2)
