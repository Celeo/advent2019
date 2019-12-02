import sequtils, strutils

proc processSingle(codes: var seq[int], position: int): int =
  ## Handle a single iteration of processing.
  ##
  ## Note: mutates the sequence.
  result = position + 4
  let code = codes[position]
  if code == 99:
    return -1
  let arg1 = codes[position + 1]
  let arg2 = codes[position + 2]
  let arg3 = codes[position + 3]
  if code == 1:
    codes[arg3] = codes[arg1] + codes[arg2]
  elif code == 2:
    codes[arg3] = codes[arg1] * codes[arg2]

proc processAll(codes: seq[int], noun = 12, verb = 2): seq[int] =
  ## Process every code in the sequence until reaching code 99.
  var codesCopy = codes
  codesCopy[1] = noun
  codesCopy[2] = verb
  var position = 0
  while position != -1:
    position = processSingle(codesCopy, position)
  codesCopy

proc guessInputs(codes: seq[int], desired: int): (int, int) =
  ## Determine the inputs required to get the desired value in the opcode sequence.
  ##
  ## "Guesses" noun and verb from [0, 0] to [99, 99].
  var noun = 0
  var verb = 0
  while true:
    var testCodes = codes
    let testResult = processAll(testCodes, noun, verb)
    if testResult[0] == desired:
      return (noun, verb)
    verb.inc()
    if verb == 99:
      verb = 0
      noun.inc()

when isMainModule:
  let codes = readFile("input.txt").strip().split(",").map(parseInt)
  let part1Codes = processAll(codes)
  echo("Part 1: " & $part1Codes[0])
  let (noun, verb) = guessInputs(codes, 19690720)
  echo("Part 2: " & $(100 * noun + verb))
