import Algorithms

struct Day15: AdventDay {
  var data: String

  struct Position: Hashable {
    var row: Int
    var column: Int

    public func advancedBy(_ input: Input) -> Position {
      switch input {
      case .up: return Position(row: row - 1, column: column)
      case .left: return Position(row: row, column: column - 1)
      case .right: return Position(row: row, column: column + 1)
      case .down: return Position(row: row + 1, column: column)
      }
    }
  }

  struct Board {
    var walls: Set<Position>
    var boxes: Set<Position>

  }

  enum Input: Character {
    case up = "^"
    case left = "<"
    case right = ">"
    case down = "v"
  }

  // board, starting position, inputs
  var parsedInput: (Board, Position, [Input]) {
    let splitData = data.split(separator: "\n\n")

    let map = splitData[0]
    let inputs = splitData[1]

    let mappedInputs = inputs
      .components(separatedBy: .whitespacesAndNewlines)
      .joined()
      .compactMap {
        Input(rawValue: $0)
      }

    var walls: Set<Position> = []
    var boxes: Set<Position> = []
    var startingPosition: Position = Position(row: 0, column: 0)

    let rows = map.components(separatedBy: .whitespacesAndNewlines)

    for (rowIndex, row) in rows.enumerated() {
      for (columnIndex, character) in row.enumerated() {
        if character == "#" {
          walls.insert(Position(row: rowIndex, column: columnIndex))
        } else if character == "O" {
          boxes.insert(Position(row: rowIndex, column: columnIndex))
        } else if character == "@" {
          startingPosition = Position(row: rowIndex, column: columnIndex)
        }
      }
    }

    return (Board(walls: walls, boxes: boxes), startingPosition, mappedInputs)
  }


  func part1() -> Any {
    let (board, startingPosition, inputs) = parsedInput

    var inputsToProcess: Deque<Input> = .init(inputs)
    var currentPosition: Position = startingPosition

    let walls = board.walls
    var boxes = board.boxes

    while let currentInput = inputsToProcess.popFirst() {
      let nextPotentialPosition = currentPosition.advancedBy(currentInput)

      let isWall = walls.contains(nextPotentialPosition)
      guard !isWall else {
        // Nothing we can do if it's a wall.
        continue
      }

      let isBox = boxes.contains(nextPotentialPosition)
      guard isBox else {
        // If it's _not_ a box, we just move there.
        currentPosition = nextPotentialPosition
        continue
      }

      let boxesChain = boxes.chainOfBoxes(startingAt: nextPotentialPosition, direction: currentInput)
      let spaceAfterChain = boxesChain.last!.advancedBy(currentInput)

      guard !walls.contains(spaceAfterChain) else {
        // If the chain ends at the wall, we can't move.
        continue
      }

      currentPosition = nextPotentialPosition
      boxes.remove(nextPotentialPosition)
      boxes.insert(spaceAfterChain)
    }
    
    let score = boxes.map {
      $0.row * 100 + $0.column
    }

    return score.reduce(0, +)
  }

  func part2() -> Any {
    return 1
  }
}


extension Set<Day15.Position> {
  func chainOfBoxes(startingAt startPosition: Day15.Position, direction: Day15.Input) -> [Day15.Position] {
    var boxes: [Day15.Position] = [startPosition]

    var nextPosition: Day15.Position? = startPosition.advancedBy(direction)

    while let innerNextPosition = nextPosition, self.contains(innerNextPosition) {
      boxes.append(innerNextPosition)

      nextPosition = innerNextPosition.advancedBy(direction)
    }

    return boxes
  }
}
