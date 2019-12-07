import sequtils, strformat, strutils, tables
import simple_graph # https://github.com/erhlee-bird/simple_graph

proc findOutward(graph: DirectedGraph, node: string, distances: var TableRef[string, int], length = 0) =
  let orbiters = graph.edges().filterIt(it[0] == node).mapIt(it[1])
  distances[node] = length
  if orbiters.len() == 0:
    return
  for orbiter in orbiters:
    findOutward(graph, orbiter, distances, length + 1)

# proc findBetween(graph: DirectedGraph, a: string, b: string, distances: var TableRef[string, int], length = 0) =
#   for (left, right) in graph.edges().filterIt(it[0] == a or it[1] == a).mapIt((it[0], it[1])):
#     echo(left, " ", right)
#   distances[a] = length
#   if orbiters.len() <= 1:
#     return
#   for orbiter in orbiters:
#     findBetween(graph, orbiter, b, distances, length + 1)

when isMainModule:
  let
    data = readFile("input.txt").strip().splitLines()
    graph = DirectedGraph[string]()
  graph.initGraph()
  for line in data:
    let parts = line.split(")")
    let
      source = parts[0]
      orbiter = parts[1]
    if source notin graph.nodes():
      graph.addNode(source)
    if orbiter notin graph.nodes():
      graph.addNode(orbiter)
    graph.addEdge(source, orbiter)

  block:
    var distances = newTable[string, int]()
    findOutward(graph, "COM", distances)
    var distanceValues: seq[int] = @[]
    for (k, v) in distances.pairs():
      echo(&"{k}: {v}")
      distanceValues.add(v)
    echo("Part 1: ", distanceValues.foldl(a + b))

  # block:
  #   var distances = newTable[string, int]()
  #   findBetween(graph, "SAN", "YOU", distances)
  #   var distanceValues: seq[int] = @[]
  #   for (k, v) in distances.pairs():
  #     echo(&"{k}: {v}")
  #     distanceValues.add(v)
  #   echo("Part 2: ", distanceValues.foldl(a + b))
