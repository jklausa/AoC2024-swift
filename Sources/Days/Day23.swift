import Algorithms

struct Day23: AdventDay {
  var data: String

  struct Edge {
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
    return 0
  }
}
