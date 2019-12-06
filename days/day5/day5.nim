import algorithm, math,
  logging, rdstdin,
  sequtils, strformat,
  strutils, tables

#[
  -------------------------------------------
  Opcode    Parameters   Functionality
  -------------------------------------------
  1         3            Add arg 1 and 2, store result in arg 3
  2         3            Multiply arg 1 and 2, store result in arg 3
  3         1            Takes 1 value from input and saves it in arg 1
  4         1            Outputs the value in arg 1
  5         2            If (arg 1 != 0), then sets the position to arg 2
  6         2            If (arg 1 == 0), then sets the position to arg 2
  7         3            Saves 1 in arg 3 if (arg 1 < arg 2) else saves 0 to arg 3
  8         3            Saves 1 in arg 3 if (arg 1 == arg 2) else saves 0 to arg 3
  99        None         Halt


  -------------------------------------------------------------
  Parameter Mode    Name            Functionality
  -------------------------------------------------------------
  0                 Position        Uses the value of the cell in the opcode list at the argument's positon
  1                 Immediate       Uses the value of the argument


  --------------------------------------
  Instruction Breakdown
  --------------------------------------

    ABCDE
    1002

    DE - two-digit opcode,      02 == opcode 2
    C - mode of 1st parameter,  0 == position mode
    B - mode of 2nd parameter,  1 == immediate mode
    A - mode of 3rd parameter,  0 == position mode, omitted due to being a leading zero

    Length will be dependent on the number of arguments for the operation
]#

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
const argModePosition = 0
const argModeImmediate = 1

type
  Opcode = object
    code: int
    argCount: int
    argModes: seq[int]

proc newOpcode(code: int, argCount: int, argModes: seq[int]): Opcode =
  Opcode(code: code, argCount: argCount, argModes: argModes)

proc `$`(o: Opcode): string =
  &"Opcode: code = {o.code}, argCount = {o.argCount}, argModes = {o.argModes}"

proc parseOpcode(code: int): Opcode =
  debug(&"Parsing opcode of {code}")
  var s = $code
  while s.len() < 4:
    s = "0" & s
  let opcode = s[^2..^1].join("").parseInt()
  var argModes = s[0..^3].toSeq().reversed().mapIt(($it).parseInt())
  let argCount = argumentCount[opcode]
  while argModes.len() < argCount:
    # debug("Adding padding 0 to opcode argModes")
    argModes.add(argModePosition)
  result = newOpcode(opcode, argCount, argModes)
  debug(result)

proc processSingle(codes: var seq[int], position: int): int =
  debug(&"processSingle(), position = {position}")
  let code = codes[position]
  let opcode = parseOpcode(code)
  let args = codes[(position + 1)..(position + opcode.argCount)]
  if opcode.code == 99:
    return -1
  elif opcode.code == 1:
    debug("opcode.code == 1")
    let
      arg1 = if opcode.argModes[0] == argModeImmediate: codes[position + 1] else: codes[codes[position + 1]]
      arg2 = if opcode.argModes[1] == argModeImmediate: codes[position + 2] else: codes[codes[position + 2]]
    codes[codes[position + 3]] = arg1 + arg2
  elif opcode.code == 2:
    debug("opcode.code == 2")
    let
      arg1 = if opcode.argModes[0] == argModeImmediate: codes[position + 1] else: codes[codes[position + 1]]
      arg2 = if opcode.argModes[1] == argModeImmediate: codes[position + 2] else: codes[codes[position + 2]]
    codes[codes[position + 3]] = arg1 * arg2
  elif opcode.code == 3:
    debug("opcode.code == 3")
    let val = readLineFromStdin("Enter value: ").parseInt()
    debug("\n\n")
    if opcode.argModes[0] == argModeImmediate:
      codes[position + 1] = val
    else:
      codes[codes[position + 1]] = val
  elif opcode.code == 4:
    debug("opcode.code == 4")
    var val = 0
    if opcode.argModes[0] == argModeImmediate:
      val = codes[position + 1]
    else:
      val = codes[codes[position + 1]]
    echo(val)
  elif opcode.code == 5:
    debug("opcode.code == 5")
    let
      arg1 = if opcode.argModes[0] == argModeImmediate: codes[position + 1] else: codes[codes[position + 1]]
      arg2 = if opcode.argModes[1] == argModeImmediate: codes[position + 2] else: codes[codes[position + 2]]
    if arg1 != 0:
      debug(&"Position tracker is now {arg2}")
      return arg2
  elif opcode.code == 6:
    debug("opcode.code == 6")
    let
      arg1 = if opcode.argModes[0] == argModeImmediate: codes[position + 1] else: codes[codes[position + 1]]
      arg2 = if opcode.argModes[1] == argModeImmediate: codes[position + 2] else: codes[codes[position + 2]]
    if arg1 == 0:
      debug(&"Position tracker is now {arg2}")
      return arg2
  elif opcode.code == 7:
    debug("opcode.code == 7")
    let
      arg1 = if opcode.argModes[0] == argModeImmediate: codes[position + 1] else: codes[codes[position + 1]]
      arg2 = if opcode.argModes[1] == argModeImmediate: codes[position + 2] else: codes[codes[position + 2]]
    let valueToStore = if arg1 < arg2:
      1
    else:
      0
    if opcode.argModes[2] == argModeImmediate:
      codes[position + 3] = valueToStore
    else:
      codes[codes[position + 1]] = valueToStore
  elif opcode.code == 8:
    debug("opcode.code == 8")
    let
      arg1 = if opcode.argModes[0] == argModeImmediate: codes[position + 1] else: codes[codes[position + 1]]
      arg2 = if opcode.argModes[1] == argModeImmediate: codes[position + 2] else: codes[codes[position + 2]]
    let valueToStore = if arg1 == arg2:
      1
    else:
      0
    if opcode.argModes[2] == argModeImmediate:
      codes[position + 3] = valueToStore
    else:
      codes[codes[position + 1]] = valueToStore
  else:
    error(&"Unknown opcode {opcode.code}")
    quit(1)
  let positionAdvance = args.len() + 1
  debug(&"Advancing position by {positionAdvance}")
  position + positionAdvance

proc processAll(codes: seq[int]): seq[int] =
  var
    codesMut = codes
    position = 0
  while position != -1:
    position = processSingle(codesMut, position)
  codesMut

when isMainModule:
  addHandler(newConsoleLogger(levelThreshold = lvlDebug))
  let codes = readFile("input.txt").strip().split(",").map(parseInt)
  discard processAll(codes)
  # 10762683 is too low for part 2
  # FIXME some of the examples for part 2 fail
