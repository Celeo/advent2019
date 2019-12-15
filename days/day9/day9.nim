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
  9: 1,
  99: 0
}.toTable()

type
  ArgMode = enum
    amPosition = 0
    amImmediate = 1
    amRelative = 2

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

proc getAt(codes: seq[int], position: int, relativeBase: int, offset: int, argMode: ArgMode): int =
  debug(&"getAt(), position = {position}, relativeBase = {relativeBase}, offset = {offset}, argMode = {argMode}")
  if argMode == amPosition:
    codes[codes[position + offset]]
  elif argMode == amImmediate:
    codes[position + offset]
  elif argMode == amRelative:
    codes[codes[position + offset] + relativeBase]
  else:
    error(&"getAt(): unknown arg mode {argMode}")
    quit(1)

proc setAt(codes: var seq[int], position: int, relativeBase: int, offset: int, argMode: ArgMode, value: int) =
  if argMode == amPosition:
    codes[codes[position + offset]] = value
  elif argMode == amImmediate:
    error("Writing to a vaue in immediate mode is invalid")
    quit(1)
  elif argMode == amRelative:
    codes[codes[position + offset] + relativeBase] = value
  else:
    error(&"setAt(): unknown arg mode {argMode}")
    quit(1)

proc processSingle(codes: var seq[int], position: var int, relativeBase: var int) =
  debug(&"New processor pass, position is {position}")
  let code = codes[position]
  let opcode = parseOpcode(code)
  let args = codes[(position + 1)..(position + opcode.argCount)]
  if opcode.code == 99:
    position = -1
    return
  elif opcode.code == 1:
    debug("opcode.code is 1")
    let
      arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, relativeBase, 2, opcode.argModes[1])
    setAt(codes, position, relativeBase, 3, opcode.argModes[2], arg1 + arg2)
  elif opcode.code == 2:
    debug("opcode.code is 2")
    let
      arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, relativeBase, 2, opcode.argModes[1])
    setAt(codes, position, relativeBase, 3, opcode.argModes[2], arg1 * arg2)
  elif opcode.code == 3:
    debug("opcode.code is 3")
    let value = readLineFromStdin("Enter value: ").parseInt()
    setAt(codes, position, relativeBase, 1, opcode.argModes[0], value)
  elif opcode.code == 4:
    debug("opcode.code is 4")
    let value = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
    echo(value)
  elif opcode.code == 5:
    debug("opcode.code is 5")
    let
      arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, relativeBase, 2, opcode.argModes[1])
    if arg1 != 0:
      debug(&"Moving position tracker to {arg2}")
      position = arg2
      return
  elif opcode.code == 6:
    debug("opcode.code is 6")
    let
      arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, relativeBase, 2, opcode.argModes[1])
    if arg1 == 0:
      debug(&"Moving position tracker to {arg2}")
      position = arg2
      return
  elif opcode.code == 7:
    debug("opcode.code is 7")
    let
      arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, relativeBase, 2, opcode.argModes[1])
    let value = if arg1 < arg2: 1 else: 0
    setAt(codes, position, relativeBase, 3, opcode.argModes[2], value)
  elif opcode.code == 8:
    debug("opcode.code is 8")
    let
      arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
      arg2 = getAt(codes, position, relativeBase, 2, opcode.argModes[1])
    let value = if arg1 == arg2: 1 else: 0
    setAt(codes, position, relativeBase, 3, opcode.argModes[2], value)
  elif opcode.code == 9:
    debug("opcode.code is 9")
    let arg1 = getAt(codes, position, relativeBase, 1, opcode.argModes[0])
    debug(&"Moving relative base by {arg1} to {relativeBase + arg1}")
    relativeBase += arg1
  else:
    error(&"Unknown opcode {opcode.code}")
    quit(1)
  let positionAdvance = args.len() + 1
  debug(&"Advancing position by {positionAdvance}")
  position += positionAdvance

proc processAll(codes: seq[int]): seq[int] =
  var
    codesMut = codes
    position = 0
    relativeBase = 0
  while position != -1:
    processSingle(codesMut, position, relativeBase)
  codesMut

proc padMemory(codes: seq[int]): seq[int] =
  var longCodes = newSeqUninitialized[int](2 ^ 16)
  for i in 0..<codes.len():
    longCodes[i] = codes[i]
  longcodes

when isMainModule:
  addHandler(newConsoleLogger(levelThreshold = lvlInfo))
  let raw = readFile("input.txt").strip().split(",").map(parseInt)
  let codes = padMemory(raw)
  discard processAll(codes)
