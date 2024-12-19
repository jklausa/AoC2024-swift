import Algorithms

struct Day18: AdventDay {
  init(data: String) {
    self.data = data
  }

  init(data: String, inputSize: (Int, Int)) {
    self.data = data
    self.inputSize = inputSize
  }

  var data: String
  var inputSize = (70, 70)

  enum Direction: Hashable, CaseIterable {
    case up
    case down
    case left
    case right
  }

  struct Position: Hashable {
    let row: Int
    let column: Int

    public func advancedBy(_ input: Direction) -> Position {
      switch input {
      case .up: return Position(row: row - 1, column: column)
      case .left: return Position(row: row, column: column - 1)
      case .right: return Position(row: row, column: column + 1)
      case .down: return Position(row: row + 1, column: column)
      }
    }

    func isValidPosition(walls: Set<Position>, bounds: (Int, Int)) -> Bool {
      guard row >= 0, row <= bounds.0,
            column >= 0, column <= bounds.1 else {
        return false
      }

      return !walls.contains(self)
    }

  }

  var walls: [Position] {
      data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .map {
        $0.split(separator: ",")
      }
      .compactMap {
        guard let column = $0.first,
              let row = $0.last,
              let intColumn = Int(column),
              let intRow = Int(row) else {
          return nil
        }

        return Position(row: intRow, column: intColumn)
      }
  }

  func findShortestPath(walls: Set<Position>) -> Int {
    let startingPoint = Position(row: 0, column: 0)
    let destination = Position(row: inputSize.0, column: inputSize.1)

    var pathsToCheck: Deque<Position> = [startingPoint]
    var length: [Position: Int] = [startingPoint: 0]

    while let currentPath = pathsToCheck.popFirst() {
      guard currentPath != destination else {
        continue
      }

      let validNextSteps = Direction
        .allCases
        .map { currentPath.advancedBy($0) }
        .filter { $0.isValidPosition(walls: walls, bounds: inputSize) }

      for nextStep in validNextSteps {
        let currentPrice = length[currentPath] ?? 0
        let existingPathToNextNode = length[nextStep] ?? Int.max

        guard currentPrice + 1 < existingPathToNextNode else {
          continue
        }

        length[nextStep] = currentPrice + 1
        pathsToCheck.append(nextStep)
      }
    }

    return length[destination] ?? -1
  }


  func part1() -> Any {
    let currentWalls: Set<Position> = Set(walls.prefix(1024))

    let path = findShortestPath(walls: currentWalls)

    return path
  }

  func part2() -> Any {
    var currentWalls: Set<Position> = Set(walls.prefix(1024))

    for newWall in walls.dropFirst(1024) {
      currentWalls.insert(newWall)
      let path = findShortestPath(walls: currentWalls)

      if path == -1 {
        return ("\(newWall.column),\(newWall.row)")
      }
    }

    return "No solution found"
  }
}
