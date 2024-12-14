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

  func distinctPlots(for character: Character, locations: [Plot], matrix: [[Character]]) -> [Set<
    Plot
  >] {
    var nodesToVisit = Deque(locations)
    var distinctPlots: [Set<Plot>] = []

    while let currentNode = nodesToVisit.popFirst() {
      guard
        let matchingIndex = distinctPlots.firstIndex(where: { set in set.contains(currentNode) })
      else {
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
      let down = matrix[safe: currentNode.row + 1]?[safe: currentNode.column]

      let touching = [left, right, up, down]
        .compactMap { $0 }
        .filter { $0 == plantType }

      count += (4 - touching.count)
    }

    return count
  }

  func perimeter(plantType: Character, plots: [Plot], matrix: [[Character]]) -> [Plot] {
    var nodesToCheck = Deque(plots)

    var perimeter: Set<Plot> = []
    while let currentNode = nodesToCheck.popFirst() {
      let adjacents = [currentNode.left, currentNode.right, currentNode.up, currentNode.down]

      let adjacentCharacters = adjacents.compactMap {
        matrix[safe: $0.row]?[safe: $0.column]
      }

      // if there is a nil, then it means that the character is on the edge, so it's a perimeter
      if adjacentCharacters.count < 4 {
        perimeter.insert(currentNode)
        continue
      }

      // If any of the adjacent characters are not the same as the plant type, then it's a perimeter
      if !adjacentCharacters.allSatisfy({ $0 == plantType }) {
        perimeter.insert(currentNode)
      }
    }

    return Array(perimeter)
  }

  func countCorners(plantType: Character, plots: [Plot], matrix: [[Character]]) -> Int {
    // corners are the same count as sides

    // corners are: top left, top right, bottom right, bottom left
    // it's a corner if the adjacent nodes are not the same as the plant type

    var count: Int = 0

    for plot in plots {
      let isTopLeftCorner = matrix[plot.left] != plantType && matrix[plot.up] != plantType
      let isTopRightCorner = matrix[plot.right] != plantType && matrix[plot.up] != plantType
      let isBottomLeftCorner = matrix[plot.left] != plantType && matrix[plot.down] != plantType
      let isBottomRightCorner = matrix[plot.right] != plantType && matrix[plot.down] != plantType

      count +=
        [isTopLeftCorner, isTopRightCorner, isBottomLeftCorner, isBottomRightCorner].filter { $0 }
        .count
    }

    return count
  }

  func part1() -> Any {
    let matrix = parseMatrix()
    let plots = plots(matrix: matrix)

    let calculatedDistinctPlots =
      plots
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
    let matrix = parseMatrix()
    let plots = plots(matrix: matrix)

    let calculatedDistinctPlots =
      plots
      .values
      .map {
        let key = matrix[$0.first!.row][$0.first!.column]
        return distinctPlots(for: key, locations: $0, matrix: matrix)
      }
      .flatMap { $0 }

    let perimeters = calculatedDistinctPlots.map { set in
      let key = matrix[set.first!.row][set.first!.column]
      return calculatePerimeter(plantType: key, plots: Array(set), matrix: matrix)
    }

    let newPerimeter = calculatedDistinctPlots.map { set in
      let key = matrix[set.first!.row][set.first!.column]
      let perimeterPlots = perimeter(plantType: key, plots: Array(set), matrix: matrix)

      let corners = countCorners(plantType: key, plots: perimeterPlots, matrix: matrix)

      print("corner for \(key): \(corners)")

      return corners * perimeterPlots.count
    }

    print(perimeters)
    print(newPerimeter)

    return newPerimeter.reduce(0, +)
    //    entities.map { $0.max() ?? 0 }.reduce(0, +)
  }
}

extension Collection {
  // Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

extension [[Character]] {
  subscript(at: Day12.Plot) -> Character? {
    self[safe: at.row]?[safe: at.column]
  }
}
