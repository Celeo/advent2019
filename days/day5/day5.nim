import algorithm, math,
  logging, rdstdin,
  sequtils, strformat,
  strutils, tables

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
    ## Represent the two types of argument modes.
    amPosition = 0
    amImmediate = 1

  Opcode = object
    ## Represent all the parts of a complex opcode.
    code: int
    argCount: int
    argModes: seq[ArgMode]

proc newOpcode(code: int, argCount: int, argModes: seq[ArgMode]): Opcode =
  ## Create a new Opcode object.
  Opcode(code: code, argCount: argCount, argModes: argModes)

proc parseOpcode(code: int): Opcode =
  ## Parse the complex opcode into its individual components.
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

proc processSingle(codes: var seq[int], position: int): int =
  ## Process a single instruction.
  ##
  ## **Returns**: the new position
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
    let val = readLineFromStdin("Enter value: ").parseInt()
    debug("\n\n")
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
    echo(val)
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

proc processAll(codes: seq[int]): seq[int] =
  ## Process the entire sequence of codes.
  var
    codesMut = codes
    position = 0
  while position != -1:
    position = processSingle(codesMut, position)
  codesMut

when isMainModule:
  addHandler(newConsoleLogger(levelThreshold = lvlInfo))
  let codes = readFile("input.txt").strip().split(",").map(parseInt)
  discard processAll(codes)
