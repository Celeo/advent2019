import math, sequtils, strutils

when isMainModule:
  let
    data = readFile("input.txt").strip()
    width = 25
    height = 6
  let perLayer = width * height

  var layers: seq[string] = @[]
  for i in 0..<(data.len() / perLayer).floor().toInt():
    layers.add(data[(i * perLayer)..((i + 1) * perLayer - 1)])

  block:
    var
      layerWithFewest: seq[char] = @[]
      fewest = 2 ^ 32
    for layer in layers:
      let zeroes = layer.count('0')
      if zeroes < fewest:
        layerWithFewest = layer[0..^1].toSeq()
        fewest = zeroes
    echo("Part 1: ", layerWithFewest.count('1') * layerWithFewest.count('2'))

  block:
    var image = layers[0]
    for layer in layers[1..^1]:
      var replacement = ""
      for pixel in 0..<perLayer:
        if image[pixel] == '2':
          replacement &= layer[pixel]
        else:
          replacement &= image[pixel]
      image = replacement
    echo("Part 2:")
    for i in 0..<height:
      echo(image[(i * width)..(i + 1) * width - 1].replace('0', ' ').replace('1', 'x'))
