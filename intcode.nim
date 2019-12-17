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

  Machine* = ref object
    codes: seq[int]
    position: int
    relativeBase: int
    inputs: seq[int]
    outputs: seq[int]

proc newOpcode(code: int, argCount: int, argModes: seq[ArgMode]): Opcode =
  ## Create a new `Opcode` object.
  Opcode(code: code, argCount: argCount, argModes: argModes)

proc newMachine*(codes: seq[int], inputs: seq[int] = @[]): Machine =
  ## Create a new `Machine` from the instructions.
  var longCodes = newSeqUninitialized[int](2 ^ 16)
  for i in 0..<codes.len():
    longCodes[i] = codes[i]
  Machine(
    codes: longcodes,
    position: 0,
    relativeBase: 0,
    inputs: inputs,
    outputs: @[]
  )

proc newMachineFromFile*(path: string, inputs: seq[int] = @[]): Machine =
  ## Load a new `Machine` from a file's content.
  newMachine(readFile(path).strip().split(",").map(parseInt), inputs)

proc `$`*(m: Machine): string =
  ## Return a string representation of the machine.
  &"<Machine, inputs: {m.inputs}, outputs: {m.outputs}>"

proc parseOpcode(code: int): Opcode =
  ## Parse an instruction into an `Opcode` object for easiser reference.
  var s = $code
  while s.len() < 4:
    s = "0" & s
  let opcode = s[^2..^1].join("").parseInt()
  var argModes = s[0..^3].toSeq().reversed().mapIt(ArgMode(($it).parseInt()))
  let argCount = argumentCount[opcode]
  while argModes.len() < argCount:
    argModes.add(amPosition)
  newOpcode(opcode, argCount, argModes)

proc getAt(m: Machine, offset: int, argMode: ArgMode): int =
  ## Retrieve a value in the instruction set, following the different argument lookup modes.
  debug(&"getAt(), position = {m.position}, relativeBase = {m.relativeBase}, offset = {offset}, argMode = {argMode}")
  if argMode == amPosition:
    m.codes[m.codes[m.position + offset]]
  elif argMode == amImmediate:
    m.codes[m.position + offset]
  elif argMode == amRelative:
    m.codes[m.codes[m.position + offset] + m.relativeBase]
  else:
    error(&"getAt(): unknown arg mode {argMode}")
    quit(1)

proc setAt(m: Machine, offset: int, argMode: ArgMode, value: int) =
  ## Set a value in the instruction set, following the different argument lookup modes.
  ##
  ## Note that `amImmediate` is invalid for setting values.
  if argMode == amPosition:
    m.codes[m.codes[m.position + offset]] = value
  elif argMode == amImmediate:
    error("Writing to a vaue in immediate mode is invalid")
    quit(1)
  elif argMode == amRelative:
    m.codes[m.codes[m.position + offset] + m.relativeBase] = value
  else:
    error(&"setAt(): unknown arg mode {argMode}")
    quit(1)

proc processSingle(m: Machine) =
  ## Perform a single iteration of processing, handling a single instruction.
  debug(&"New processor pass, position is {m.position}")
  let code = m.codes[m.position]
  let opcode = parseOpcode(code)
  let args = m.codes[(m.position + 1)..(m.position + opcode.argCount)]
  if opcode.code == 99:
    m.position = -1
    return
  elif opcode.code == 1:
    debug("opcode.code is 1")
    let
      arg1 = getAt(m, 1, opcode.argModes[0])
      arg2 = getAt(m, 2, opcode.argModes[1])
    setAt(m, 3, opcode.argModes[2], arg1 + arg2)
  elif opcode.code == 2:
    debug("opcode.code is 2")
    let
      arg1 = getAt(m, 1, opcode.argModes[0])
      arg2 = getAt(m, 2, opcode.argModes[1])
    setAt(m, 3, opcode.argModes[2], arg1 * arg2)
  elif opcode.code == 3:
    debug("opcode.code is 3")
    let value = m.inputs[0]
    m.inputs.delete(0)
    setAt(m, 1, opcode.argModes[0], value)
  elif opcode.code == 4:
    debug("opcode.code is 4")
    let value = getAt(m, 1, opcode.argModes[0])
    m.outputs.add(value)
  elif opcode.code == 5:
    debug("opcode.code is 5")
    let
      arg1 = getAt(m, 1, opcode.argModes[0])
      arg2 = getAt(m, 2, opcode.argModes[1])
    if arg1 != 0:
      debug(&"Moving position tracker to {arg2}")
      m.position = arg2
      return
  elif opcode.code == 6:
    debug("opcode.code is 6")
    let
      arg1 = getAt(m, 1, opcode.argModes[0])
      arg2 = getAt(m, 2, opcode.argModes[1])
    if arg1 == 0:
      debug(&"Moving position tracker to {arg2}")
      m.position = arg2
      return
  elif opcode.code == 7:
    debug("opcode.code is 7")
    let
      arg1 = getAt(m, 1, opcode.argModes[0])
      arg2 = getAt(m, 2, opcode.argModes[1])
    let value = if arg1 < arg2: 1 else: 0
    setAt(m, 3, opcode.argModes[2], value)
  elif opcode.code == 8:
    debug("opcode.code is 8")
    let
      arg1 = getAt(m, 1, opcode.argModes[0])
      arg2 = getAt(m, 2, opcode.argModes[1])
    let value = if arg1 == arg2: 1 else: 0
    setAt(m, 3, opcode.argModes[2], value)
  elif opcode.code == 9:
    debug("opcode.code is 9")
    let arg1 = getAt(m, 1, opcode.argModes[0])
    debug(&"Moving relative base by {arg1} to {m.relativeBase + arg1}")
    m.relativeBase += arg1
  else:
    error(&"Unknown opcode {opcode.code}")
    quit(1)
  let positionAdvance = args.len() + 1
  debug(&"Advancing position by {positionAdvance}")
  m.position += positionAdvance

proc processLoop*(m: Machine) =
  ## Process all a machine's instructions until it encounters instruction code 99.
  while m.position != -1:
    processSingle(m)

when isMainModule:
  let machine5 = newMachineFromFile("./days/day5/input.txt", @[5])
  machine5.processLoop()
  assert machine5.outputs == @[11189491]

  let machine9 = newMachineFromFile("./days/day9/input.txt", @[1])
  machine9.processLoop()
  assert $machine9.outputs == "@[2738720997]"
