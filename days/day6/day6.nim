import sequtils, strutils, sets, tables
import simple_graph # https://github.com/erhlee-bird/simple_graph

proc findOutward(graph: DirectedGraph, node: string, distances: var TableRef[string, int], length = 0) =
  let orbiters = graph.edges().filterIt(it[0] == node).mapIt(it[1])
  distances[node] = length
  if orbiters.len() == 0:
    return
  for orbiter in orbiters:
    findOutward(graph, orbiter, distances, length + 1)

proc findBetween(graph: DirectedGraph, currentPt: string, endPt: string, seen: var HashSet[string], length = 0): int =
  seen.incl(currentPt)
  for (left, right) in graph.edges().filterIt(it[0] == currentPt or it[1] == currentPt).mapIt((it[0], it[1])):
    if left == endPt:
      return length
    if right == endPt:
      return length
    if right notin seen:
      let rightLen = findBetween(graph, right, endPt, seen, length + 1)
      if rightLen != 0:
        return rightLen
    if left notin seen:
      let leftLen = findBetween(graph, left, endPt, seen, length + 1)
      if leftLen != 0:
        return leftLen

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
      distanceValues.add(v)
    echo("Part 1: ", distanceValues.foldl(a + b))

  block:
    var seen = initHashSet[string]()
    let length = findBetween(graph, "SAN", "YOU", seen)
    echo("Part 2: ", length - 1)
