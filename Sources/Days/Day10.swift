struct Day10: AdventDay {
  var data: String

  struct Point: Hashable {
    let row: Int
    let column: Int
  }

  enum ResultType {
    case totalPaths
    case numberOfNinesReachable
  }
  func calculateMatrix() -> [[Int]] {
    data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .map { $0.map { Int(String($0))! } }
  }

  func findTrailpathsStarts(matrix: [[Int]]) -> [Point] {
    matrix.enumerated().reduce(into: []) { result, row in
      for column in row.element.enumerated() {
        if column.element == 0 {
          result.append(
            Point(
              row: row.offset,
              column: column.offset)
          )
        }
      }
    }
  }

  func trailpathsStartingFrom(_ start: Point, in matrix: [[Int]], resultType: ResultType) -> Int {
    var pointsToCheck: [([Point], Point)] = [([], start)]

    var seenNines: Set<Point> = []
    var totalPaths = 0

    while let (path, currentPoint) = pointsToCheck.popLast() {
      guard matrix[currentPoint.row][currentPoint.column] != 9 else {
        seenNines.insert(currentPoint)
        totalPaths += 1
        continue
      }

      let left: Point? = {
        guard currentPoint.column > 0 else { return nil }

        return Point(
          row: currentPoint.row,
          column: currentPoint.column - 1)
      }()

      let right: Point? = {
        guard currentPoint.column < matrix[currentPoint.row].count - 1 else { return nil }

        return Point(
          row: currentPoint.row,
          column: currentPoint.column + 1)
      }()

      let up: Point? = {
        guard currentPoint.row > 0 else { return nil }

        return Point(
          row: currentPoint.row - 1,
          column: currentPoint.column)
      }()

      let down: Point? = {
        guard currentPoint.row < matrix.count - 1 else { return nil }

        return Point(
          row: currentPoint.row + 1,
          column: currentPoint.column)
      }()

      let potentialPoints = [left, right, up, down]
        .compactMap { $0 }
        .filter {
          matrix[$0.row][$0.column] == matrix[currentPoint.row][currentPoint.column] + 1
        }

      for point in potentialPoints {
        let path = path + [currentPoint]
        pointsToCheck.append((path, point))
      }
    }

    switch resultType {
    case .numberOfNinesReachable:
      return seenNines.count
    case .totalPaths:
      return totalPaths
    }
  }

  func part1() -> Any {
    let matrix = calculateMatrix()
    let trailpathsStarts = findTrailpathsStarts(matrix: matrix)

    return
      trailpathsStarts
      .map { trailpathsStartingFrom($0, in: matrix, resultType: .numberOfNinesReachable) }
      .reduce(0, +)
  }

  func part2() -> Any {
    let matrix = calculateMatrix()
    let trailpathsStarts = findTrailpathsStarts(matrix: matrix)

    return
      trailpathsStarts
      .map { trailpathsStartingFrom($0, in: matrix, resultType: .totalPaths) }
      .reduce(0, +)
  }
}
