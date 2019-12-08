import math, sequtils, strutils

when isMainModule:
  let
    data = readFile("input.txt").strip()
    width = 25
    height = 6
  let perLayer = width * height
  var
    layerWithFewest: seq[char] = @[]
    fewest = 2 ^ 32
  for i in 0..<(data.len() / perLayer).floor().toInt():
    let
      s = i * perLayer
      e = (i + 1) * perLayer - 1
    let layer = data[s..e]
    let zeros = layer.count('0')
    if zeros < fewest:
      layerWithFewest = layer[0..^1].toSeq()
      fewest = zeros
  echo(layerWithFewest.count('1') * layerWithFewest.count('2'))
