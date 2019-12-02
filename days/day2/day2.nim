import sequtils, strformat, strutils

proc processSingle(codes: var seq[int], position: int): int =
  ## Handles a single iteration of processing.
  ##
  ## Note: mutates the sequence.
  result = position + 4
  let code = codes[position]
  if code == 99:
    return -1
  elif code == 1:
    let arg1 = codes[position + 1]
    let arg2 = codes[position + 2]
    let arg3 = codes[position + 3]
    codes[arg3] = codes[arg1] + codes[arg2]
  elif code == 2:
    let arg1 = codes[position + 1]
    let arg2 = codes[position + 2]
    let arg3 = codes[position + 3]
    codes[arg3] = codes[arg1] * codes[arg2]
  else:
    echo(&"Unknown code {code} at position {position}")
    quit(1)

proc processAll(codes: var seq[int]) =
  ## Processes every code in the sequence until reaching code 99.
  ##
  ## Note: mutates the sequence.
  var position = 0
  while position != -1:
    position = processSingle(codes, position)

when isMainModule:
  var codes = readFile("input.txt").strip().split(",").map(parseInt)
  processAll(codes)
  echo(codes[0])
