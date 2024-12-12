import Collections

struct Day12: AdventDay {
  var data: String

  struct Plot: Hashable {
    var row: Int
    var column: Int

    func isAdjacent(to other: Plot) -> Bool {
      abs(row - other.row) == 1 && abs(column - other.column) == 1
    }

    var left: Plot {
      Plot(row: row, column: column - 1)
    }

    var right: Plot {
      Plot(row: row, column: column + 1)
    }

    var up: Plot {
      Plot(row: row - 1, column: column)
    }

    var down: Plot {
      Plot(row: row + 1, column: column)
    }
  }

  func parseMatrix() -> [[Character]] {
    data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .map { string in
        string.map { $0 }
      }
  }

  func plots(matrix: [[Character]]) -> [Character: [Plot]] {
    matrix
      .enumerated()
      .reduce(into: [Character: [Plot]]()) { acc, enumeration in
        for (column, character) in enumeration.element.enumerated() {
          acc[character, default: []].append(
            Plot(
              row: enumeration.offset,
              column: column
            )
          )
        }
      }
  }

  func distinctPlots(for character: Character, locations: [Plot], matrix: [[Character]]) -> [Set<Plot>] {
    var nodesToVisit = Deque(locations)
    var distinctPlots: [Set<Plot>] = []

    while let currentNode = nodesToVisit.popFirst() {
      guard let matchingIndex = distinctPlots.firstIndex(where: { set in set.contains(currentNode) }) else {
        distinctPlots.append(longestPath(starting: currentNode, in: matrix))
        continue
      }

      var currentSet = distinctPlots[matchingIndex]
      currentSet.insert(currentNode)
      distinctPlots[matchingIndex] = currentSet
    }

    return distinctPlots
  }

  func longestPath(starting at: Plot, in matrix: [[Character]]) -> Set<Plot> {
    let character = matrix[at.row][at.column]

    var visited = Set<Plot>()
    var nodesToVisit = Deque([at])

    while let node = nodesToVisit.popFirst() {
      guard !visited.contains(node) else {
        continue
      }

      visited.insert(node)

      let adjacentNodes = [node.left, node.right, node.up, node.down]
        .compactMap {
          ($0, matrix[safe: $0.row]?[safe: $0.column])
        }
        .filter { $0.1 == character }

      nodesToVisit.prepend(contentsOf: adjacentNodes.map(\.0))
    }

    return visited
  }

  func calculatePerimeter(plantType: Character, plots: [Plot], matrix: [[Character]]) -> Int {
    var nodesToCheck = Deque(plots)

    var count = 0

    while let currentNode = nodesToCheck.popFirst() {

      let left = matrix[safe: currentNode.row]?[safe: currentNode.column - 1]
      let right = matrix[safe: currentNode.row]?[safe: currentNode.column + 1]
      let up = matrix[safe: currentNode.row - 1]?[safe: currentNode.column]
      let down = matrix[safe: currentNode.row + 1]?[safe:currentNode.column]

      let touching = [left, right, up, down]
        .compactMap { $0 }
        .filter { $0 == plantType }

      count += (4 - touching.count)
    }

    return count
  }

  func part1() -> Any {
    let matrix = parseMatrix()
    let plots = plots(matrix: matrix)

    let calculatedDistinctPlots = plots
      .map { (key, value) in
        (key, distinctPlots(for: key, locations: value, matrix: matrix))
      }

    let perimeters = calculatedDistinctPlots.map { (key, sets) in
      // for each set, calculate the perimeter, and then multiply by the number of plots in that set
      let perimeters = sets.map {
        let result = calculatePerimeter(plantType: key, plots: Array($0), matrix: matrix)
        return result * $0.count
      }

      // then sum all the plots for a given character
      return perimeters.reduce(0, +)
    }

    // then sum all of the plots for all characters
    return perimeters.reduce(0, +)
  }

  func part2() -> Any {
    return 0
    //    entities.map { $0.max() ?? 0 }.reduce(0, +)
  }
}

extension Collection {
  // Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
