struct Day06: AdventDay {
  var data: String

  enum Direction: String {
    case up = "^"
    case right = "v"
    case down = "<"
    case left = ">"
  }

  enum GridPoint {
    case obstacle
    case path
    case startingPosition
  }

  struct Position: Hashable {
    let row: Int
    let column: Int
  }

  // (matrix, starting position)
  func parseMatrix() -> ([[GridPoint]], Position) {
    var startingPosition: Position?

    let mappedData =
      data
      .components(separatedBy: .whitespacesAndNewlines)
      .enumerated()
      .map { x, string in
        string
          .enumerated()
          .map { y, character in
            switch character {
            case ".": return GridPoint.path
            case "#": return GridPoint.obstacle
            case "^":
              startingPosition = Position(row: x, column: y)
              return GridPoint.startingPosition
            default: fatalError()
            }
          }
      }

    return (mappedData, startingPosition!)
  }

  func isExitingTheGrid(
    matrix: [[GridPoint]],
    position: Position,
    direction: Direction
  ) -> Bool {
    switch direction {
    case .up:
      if position.row == 0 { return true }
    case .right:
      if position.column == matrix[0].count - 1 { return true }
    case .down:
      if position.row == matrix.count - 1 { return true }
    case .left:
      if position.column == 0 { return true }
    }

    return false
  }

  func part1() -> Any {
    let (matrix, startingPosition) = parseMatrix()

    var visitedPositions: Set<Position> = [startingPosition]
    var currentPosition: Position = startingPosition
    var direction: Direction = .up

    while isExitingTheGrid(
      matrix: matrix,
      position: currentPosition,
      direction: direction) == false
    {

      visitedPositions.insert(currentPosition)

      let potentialNextPosition: Position =
        switch direction {
        case .up: .init(row: currentPosition.row - 1, column: currentPosition.column)
        case .left: .init(row: currentPosition.row, column: currentPosition.column - 1)
        case .right: .init(row: currentPosition.row, column: currentPosition.column + 1)
        case .down: .init(row: currentPosition.row + 1, column: currentPosition.column)
        }

      let cellAtPotentialNextPosition = matrix[potentialNextPosition.row][
        potentialNextPosition.column]

      if cellAtPotentialNextPosition == .path || cellAtPotentialNextPosition == .startingPosition {
        currentPosition = potentialNextPosition
        continue
      }

      // we're facing an obstacle now, need to turn 90 degrees
      switch direction {
      case .up: direction = .right
      case .right: direction = .down
      case .down: direction = .left
      case .left: direction = .up
      }
    }

    // (+1) because we're breaking the loop when we'd exit the grid,
    // and we need to include that position too
    return visitedPositions.count + 1
  }

  struct VisitedPosition: Hashable {
    let position: Position
    let direction: Direction
  }

  func part2() -> Any {
    let (matrix, startingPosition) = parseMatrix()

    var loopsPositions: Set<Position> = []

    func doesLoopExistWithAdditionalPosition(
      grid: [[GridPoint]],
      extraBarricadePosition: Position,
      startingPosition: Position
    ) -> Bool {
      var visitedPositionsWithDirections: Set<VisitedPosition> = []

      var currentPosition: Position = startingPosition
      var direction: Direction = .up

      while true {
        if isExitingTheGrid(
          matrix: grid,
          position: currentPosition,
          direction: direction)
        {
          return false
        }

        let currentPositionWithDirection = VisitedPosition(
          position: currentPosition, direction: direction)
        let insertionResult = visitedPositionsWithDirections.insert(currentPositionWithDirection)

        if insertionResult.inserted == false {
          return true
        }

        let potentialNextPosition: Position =
          switch direction {
          case .up: .init(row: currentPosition.row - 1, column: currentPosition.column)
          case .left: .init(row: currentPosition.row, column: currentPosition.column - 1)
          case .right: .init(row: currentPosition.row, column: currentPosition.column + 1)
          case .down: .init(row: currentPosition.row + 1, column: currentPosition.column)
          }

        let cellAtPotentialNextPosition =
          if potentialNextPosition == extraBarricadePosition {
            GridPoint.obstacle
          } else {
            matrix[potentialNextPosition.row][potentialNextPosition.column]
          }

        if cellAtPotentialNextPosition == .path || cellAtPotentialNextPosition == .startingPosition
        {
          currentPosition = potentialNextPosition

          continue
        }

        // we're facing an obstacle now, need to turn 90 degrees
        switch direction {
        case .up: direction = .right
        case .right: direction = .down
        case .down: direction = .left
        case .left: direction = .up
        }
      }
    }

    for (rowIdx, row) in matrix.enumerated() {
      for (columnIdx, _) in row.enumerated() {

        let position = Position(row: rowIdx, column: columnIdx)
        if position == startingPosition { continue }

        if doesLoopExistWithAdditionalPosition(
          grid: matrix,
          extraBarricadePosition: position,
          startingPosition: startingPosition)
        {
          loopsPositions.insert(position)
        }
      }
    }

    return loopsPositions.count
  }
}
