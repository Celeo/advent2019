import strutils
# https://github.com/erhlee-bird/simple_graph
import simple_graph

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
