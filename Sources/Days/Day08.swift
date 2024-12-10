struct Day08: AdventDay {
  var data: String

  struct Point: Hashable {
    let x: Int
    let y: Int
  }

  func parseMatrix() -> [[Character]] {
    data
      .components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
      .map { $0.map(Character.init) }
  }

  func makeOccurencesMap(matrix: [[Character]]) -> [Character: [Point]] {
    return matrix
      .enumerated()
      .reduce(into: [Character: [Point]]()) { acc, enumeration in
        enumeration.element.enumerated().forEach { column, character in
          guard character != "." else { return }
          acc[character, default: []].append(Point(x: enumeration.offset, y: column))
        }
      }
  }

  func isValidPoint(matrix: [[Character]], point: Point) -> Bool {
    if point.x >= 0, point.x < matrix.first!.count,
       point.y >= 0, point.y < matrix.count {
      return true
    }

    return false
  }

  func part1() -> Any {
    let matrix = parseMatrix()
    let occurences = makeOccurencesMap(matrix: matrix)

    let antiNodes = occurences.map {
      var pointsToCondsider = $1
      var antinodes: Set<Point> = []

      while pointsToCondsider.count > 1 {
        let currentPoint = pointsToCondsider.removeLast()

        for point in pointsToCondsider {
          let distance = (point.x - currentPoint.x,  point.y - currentPoint.y)
          let doubleDistance = (distance.0 * 2, distance.1 * 2)

          let antinodeFromCurrentPoint = Point(x: (currentPoint.x + doubleDistance.0), y: (currentPoint.y + doubleDistance.1))
          let antinodeFromIteratedPoint = Point(x: (point.x - doubleDistance.0), y: (point.y - doubleDistance.1))

          if isValidPoint(matrix: matrix, point: antinodeFromCurrentPoint) {
            antinodes.insert(antinodeFromCurrentPoint)
          }

          if isValidPoint(matrix: matrix, point: antinodeFromIteratedPoint) {
            antinodes.insert(antinodeFromIteratedPoint)
          }
        }
      }
      return antinodes
    }

    let reduced = antiNodes.reduce(into: Set<Point>()) {
      $0.formUnion($1)
    }

    return reduced.count
  }

  func part2() -> Any {
    let matrix = parseMatrix()
    let occurences = makeOccurencesMap(matrix: matrix)

    let antiNodesP2 = occurences.map {
      var pointsToCondsider = $1
      var antinodes: Set<Point> = Set($1)

      while pointsToCondsider.count > 1 {
        let currentPoint = pointsToCondsider.removeLast()

        for point in pointsToCondsider {
          let distance = (point.x - currentPoint.x,  point.y - currentPoint.y)

          antinodes.formUnion(allValidPoints(from: currentPoint, dx: distance.0, dy: distance.1, within: matrix))
        }
      }

      return antinodes
    }

    func allValidPoints(from: Point, dx: Int, dy: Int, within matrix: [[Character]]) -> Set<Point> {
      var result: Set<Point> = []

      var nextNegativePoint = Point(x: from.x - dx, y: from.y - dy)

      while isValidPoint(matrix: matrix, point: nextNegativePoint) {
        result.insert(nextNegativePoint)

        nextNegativePoint = Point(x: nextNegativePoint.x - dx, y: nextNegativePoint.y - dy)
      }

      var nextPositivePoint = Point(x: from.x + dx, y: from.y + dy)

      while isValidPoint(matrix: matrix, point: nextPositivePoint) {
        result.insert(nextPositivePoint)

        nextPositivePoint = Point(x: nextPositivePoint.x + dx, y: nextPositivePoint.y + dy)
      }

      return result
    }

    return antiNodesP2.reduce(into: Set<Point>()) {
      $0.formUnion($1)
    }
    .count
  }
}
