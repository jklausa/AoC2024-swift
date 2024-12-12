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

    print("longest path for \(character): \(visited)")

    return visited
  }

//  func distinctPlots(for character: Character, locations: [Plot], matrix: [[Character]]) -> [Set<Plot>] {
//    var nodesToVisit = Deque(locations)
//    var visited = Set<Plot>()
//
//    var distinctPlots: [Set<Plot>] = []
//    var currentSet: Set<Plot> = [nodesToVisit.first!]
//
//    while let currentNode = nodesToVisit.popFirst() {
//      guard !visited.contains(currentNode) else {
//        continue
//      }
//
//      visited.insert(currentNode)
//
//      // up, down, left, right
//      let offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
//      let offsetsWithCharacters = offsets.map {
//        ($0, matrix[safe: currentNode.row + $0.0]?[safe: currentNode.column + $0.1])
//      }
//
//      var shouldStartNewSet = true
//      for (offset, iteratedCharacter) in offsetsWithCharacters {
//        guard iteratedCharacter == character else {
//          continue
//        }
//
//        let iteratedNode = Plot(row: currentNode.row + offset.0, column: currentNode.column + offset.1)
//        let (inserted, _) = currentSet.insert(iteratedNode)
//        nodesToVisit.append(iteratedNode)
//
//        if inserted {
//          shouldStartNewSet = false
//        }
//      }
//
//      if shouldStartNewSet {
//        distinctPlots.append(currentSet)
//        currentSet = Set([currentNode])
//      }
//
//    }
//
//    if distinctPlots.isEmpty {
//      return [currentSet]
//    }
//
//    print("distinctPlots for \(character): \(distinctPlots)")
//
//    return distinctPlots
//  }

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

    for (key, value) in calculatedDistinctPlots {
      print("distinct plots for \(key): \(value.count)")
      value.forEach {
        print($0)
      }
      print("----")
    }

    let perimeters = calculatedDistinctPlots.map { (key, sets) in
        let perimeters = sets.map {
          let result = calculatePerimeter(plantType: key, plots: Array($0), matrix: matrix)
          print("perimeter for:\(key): \(result)")

          return result * $0.count
        }
        return perimeters.reduce(0, +)
      }

      return perimeters.reduce(0, +)
    }


//      .reduce(0, +)

//    return calculatedDistinctPlots


//    for (key, value) in calculateDistinctPlots {
//      let perimeters = value.map { calculatePerimeter(plantType: key, plots: <#T##[Plot]#>, matrix: <#T##[[Character]]#>)}
//    }
//
//
//
//    let distinctPlotsOld: [Character: [Set<Plot>]] = plots.mapValues { plots in
//      var sets = [Set<Plot>]()
//
//      for plot in plots {
//        let matchingSetIndex = sets.firstIndex(where: {
//          let left = Plot(row: plot.row, column: plot.column - 1)
//          let right = Plot(row: plot.row, column: plot.column + 1)
//          let up = Plot(row: plot.row - 1, column: plot.column)
//          let down = Plot(row: plot.row + 1, column: plot.column)
//
//          return $0.contains(left) || $0.contains(right) || $0.contains(up) || $0.contains(down)
//        })
//
//        if let matchingSetIndex {
//          var currentSet = sets[matchingSetIndex]
//          currentSet.insert(plot)
//          sets[matchingSetIndex] = currentSet
//        } else {
//          let newSet = Set([plot])
//          sets.append(newSet)
//        }
//      }
//
//      if matrix[plots.first!.row][plots.first!.column] == "C" {
//        print(sets)
//      }
//
//
//      return sets
//    }
//
//    let distinctPlotPerimeters: Int = distinctPlotsOld.reduce(into: 0) { acc, dictionaryItem in
//      let distinctSets = dictionaryItem.value
//
//      let reducedSets = distinctSets.reduce(into: 0) { innerAcc, set in
//        let perimeter = calculatePerimeter(
//          plantType: dictionaryItem.key,
//          plots: Array(set),
//          matrix: matrix
//        )
//
//        print("perimeter for:\(dictionaryItem.key): \(perimeter)")
//        innerAcc += perimeter * set.count
//      }
//
//      acc += reducedSets
//    }

//    return distinctPlotPerimeters

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
