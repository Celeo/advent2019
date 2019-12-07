import sequtils, strformat, strutils
import simple_graph # https://github.com/erhlee-bird/simple_graph

proc traverse(node: string, graph: DirectedGraph, length = 0) =
  let newLength = length + 1
  let orbiters = graph.edges().filterIt(it[0] == node).mapIt(it[1])
  if orbiters.len() == 0:
    return
  echo(&"Orbiting {node} at distance {1} is/are: {orbiters}")
  for orbiter in orbiters:
    traverse(orbiter, graph, newLength)
  # TODO need to make use of 'newLength' to track all of the distances
  echo(newLength)

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
  echo("Number of direct edges: ", graph.edges().len())

  # TODO need number of both direct edges and _indirect_ edges

  #[
    Pick the "COM" point
    From that point, loop over its edges
    For each point connected via an edge, that point is 1 away
    Loop over those points' edges to find which points are connected to them
    Continue, building a length from the first point to each other point
    Sum all of those lengths
  ]#

  traverse("COM", graph)
