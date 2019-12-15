import algorithm, math, logging, sequtils, strformat, strutils, tables

const argumentCount = {
  1: 3,
  2: 3,
  3: 1,
  4: 1,
  5: 2,
  6: 2,
  7: 3,
  8: 3,
  99: 0
}.toTable()

type
  ArgMode = enum
    amPosition = 0
    amImmediate = 1

  Opcode = object
    code: int
    argCount: int
    argModes: seq[ArgMode]

proc newOpcode(code: int, argCount: int, argModes: seq[ArgMode]): Opcode =
  Opcode(code: code, argCount: argCount, argModes: argModes)

proc parseOpcode(code: int): Opcode =
  var s = $code
  while s.len() < 4:
    s = "0" & s
  let opcode = s[^2..^1].join("").parseInt()
  var argModes = s[0..^3].toSeq().reversed().mapIt(ArgMode(($it).parseInt()))
  let argCount = argumentCount[opcode]
  while argModes.len() < argCount:
    argModes.add(amPosition)
  newOpcode(opcode, argCount, argModes)

proc getAt(codes: seq[int], position: int, offset: int, argMode: ArgMode): int =
  if argMode == amImmediate:
    codes[position + offset]
  else:
    codes[codes[position + offset]]

proc processSingle(codes: var seq[int], position: int, inputs: var seq[int], output: var seq[int]): int =
  debug(&"New processor pass, position is {position}")
  let code = codes[position]
  let opcode = parseOpcode(code)
  let args = codes[(position + 1)..(position + opcode.argCount)]
  if opcode.code == 99:
    return -1
  elif opcode.code == 1:
    debug("opcode.code is 1")
    let
      arg1 = getAt(codes, position, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, 2, opcode.argModes[1])
    codes[codes[position + 3]] = arg1 + arg2
  elif opcode.code == 2:
    debug("opcode.code is 2")
    let
      arg1 = getAt(codes, position, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, 2, opcode.argModes[1])
    codes[codes[position + 3]] = arg1 * arg2
  elif opcode.code == 3:
    debug("opcode.code is 3")
    let val = inputs[0]
    inputs.delete(0)
    if opcode.argModes[0] == amImmediate:
      codes[position + 1] = val
    else:
      codes[codes[position + 1]] = val
  elif opcode.code == 4:
    debug("opcode.code is 4")
    var val = 0
    if opcode.argModes[0] == amImmediate:
      val = codes[position + 1]
    else:
      val = codes[codes[position + 1]]
    output.add(val)
  elif opcode.code == 5:
    debug("opcode.code is 5")
    let
      arg1 = getAt(codes, position, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, 2, opcode.argModes[1])
    if arg1 != 0:
      debug(&"Moving position tracker to {arg2}")
      return arg2
  elif opcode.code == 6:
    debug("opcode.code is 6")
    let
      arg1 = getAt(codes, position, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, 2, opcode.argModes[1])
    if arg1 == 0:
      debug(&"Moving position tracker to {arg2}")
      return arg2
  elif opcode.code == 7:
    debug("opcode.code is 7")
    let
      arg1 = getAt(codes, position, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, 2, opcode.argModes[1])
    let valueToStore = if arg1 < arg2: 1 else: 0
    if opcode.argModes[2] == amImmediate:
      codes[position + 3] = valueToStore
    else:
      codes[codes[position + 3]] = valueToStore
  elif opcode.code == 8:
    debug("opcode.code is 8")
    let
      arg1 = getAt(codes, position, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, 2, opcode.argModes[1])
    let valueToStore = if arg1 == arg2: 1 else: 0
    if opcode.argModes[2] == amImmediate:
      codes[position + 3] = valueToStore
    else:
      codes[codes[position + 3]] = valueToStore
  else:
    error(&"Unknown opcode {opcode.code}")
    quit(1)
  let positionAdvance = args.len() + 1
  debug(&"Advancing position by {positionAdvance}")
  position + positionAdvance

proc processAll(codes: seq[int], phase: int, signal: int): seq[int] =
  var
    codesMut = codes
    position = 0
    inputs = @[phase, signal]
  while position != -1:
    position = processSingle(codesMut, position, inputs, result)

proc getAllPhaseCombinations(): seq[seq[int]] =
  for i in 01234..43210:
    var valid = true
    let s = $i
    for c in ['0', '1', '2', '3', '4']:
      if c notin s:
        valid = false
        break
    if valid:
      result.add(s[0..^1].mapIt(($it).parseInt()))

when isMainModule:
  addHandler(newConsoleLogger(levelThreshold = lvlInfo))
  const allPhaseCombinations = getAllPhaseCombinations()
  let codes = readFile("input.txt").strip().split(",").map(parseInt)

  var largest = 0
  for phase in allPhaseCombinations:
    var signal = 0
    for i in 0..<5:
      signal = processAll(codes, phase[i], signal)[0]
    if signal > largest:
      largest = signal
  echo(largest)
