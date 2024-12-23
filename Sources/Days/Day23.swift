import Algorithms

struct Day23: AdventDay {
  var data: String

  struct Edge: Hashable {
    let from: String
    let to: String
  }

  var entities: [Edge] {
    data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n")
      .map {
        let parts = $0.split(separator: "-")

        return Edge(from: String(parts.first!), to: String(parts.last!))
      }
  }

  func part1() -> Any {
    var edges: [String: Set<String>] = [:]

    for edge in entities {
      let start = min(edge.from, edge.to)
      let end = max(edge.from, edge.to)

      edges[start, default: []].insert(end)
      edges[end, default: []].insert(start)
    }

    let relevantNodes = edges
      .keys
      .filter { $0.first == "t" }

    var triples: Set<Set<String>> = []

    for startNode in relevantNodes {
      // for every node beginning in `t`, iterate
      // over other nodes to see if they form a cycle

      let otherNodes = edges[startNode, default: []]
      for node in otherNodes {
        // we need to find if any of the nodes that the other node touches,
        // also comes back to us
        let thirdNodes = edges[node, default: []]
        for thirdNode in thirdNodes {
          if edges[thirdNode, default: []].contains(startNode) {
            triples.insert(Set([startNode, node, thirdNode]))
          }
        }
      }
    }

    return triples.count
  }

  func part2() -> Any {
    var edges: [String: Set<String>] = [:]

    for edge in entities {
      let start = min(edge.from, edge.to)
      let end = max(edge.from, edge.to)

      edges[start, default: []].insert(end)
      edges[end, default: []].insert(start)
    }

    // TIL: This is called a "maximum clique" problem:
    // https://en.wikipedia.org/wiki/Clique_(graph_theory)#Definitions
    // https://en.wikipedia.org/wiki/Bron–Kerbosch_algorithm

    // In Python, using NetworkX, this is:
    //    graph = nx.Graph()
    //
    //    for line in inputData.splitlines():
    //            graph.add_edge(line[0:2], line[3:5])
    //
    //    maxClique = max(nx.find_cliques(graph), key=len)
    //    maxClique.sort()
    //
    //    answer = ",".join(maxClique)
    //    print(answer)
    //

    let cliques = bronKerbosch(potential: [], candidates: Set(edges.keys), excluded: [], graph: edges)
    let relevantClique = cliques
      .sorted { $0.count > $1.count }
      .first?
      .sorted()
      .joined(separator: ",")

    return relevantClique ?? "No answer"
  }

  func bronKerbosch(potential: Set<String>,
                    candidates: Set<String>,
                    excluded: Set<String>,
                    graph:  [String: Set<String>]) -> [Set<String>] {

    var cliques: [Set<String>] = []

    if candidates.isEmpty && excluded.isEmpty {
      // No more work to check.
      cliques.append(potential)
      return cliques
    }

    var shadowedCandidates = candidates
    var shadowedExcluded = excluded

    for node in shadowedCandidates {
      var newPotential = potential

      newPotential.insert(node)
      let newCandidates = shadowedCandidates.intersection(graph[node, default: []])
      let newExcluded = shadowedExcluded.intersection(graph[node, default: []])

      let newClique = bronKerbosch(potential: newPotential,
                                   candidates: newCandidates,
                                   excluded: newExcluded,
                                   graph: graph)

      cliques.append(contentsOf: newClique)

      shadowedCandidates.remove(node)
      shadowedExcluded.insert(node)
    }

    return cliques
  }
}
