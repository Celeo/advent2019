import sequtils, strutils
import simple_graph # https://github.com/erhlee-bird/simple_graph

proc traverse(node: string, graph: DirectedGraph, distances: var seq[int] = @[], length = 0) =
  let orbiters = graph.edges().filterIt(it[0] == node).mapIt(it[1])
  distances.add(length)
  if orbiters.len() == 0:
    return
  for orbiter in orbiters:
    traverse(orbiter, graph, distances, length + 1)

when isMainModule:
  let data = readFile("input.txt").strip().splitLines()
  let graph = DirectedGraph[string]()
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

  var distances: seq[int] = @[]
  traverse("COM", graph, distances)
  let total: int = distances.foldl(a + b)
  echo("Part 1: ", total)
