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

  struct BigBox: Hashable {
    var left: Position
    let right: Position

    public func advancedBy(_ input: Input) -> BigBox {
      BigBox(left: left.advancedBy(input), right: right.advancedBy(input))
    }

    public func potentiallyTouchingBoxes(in direction: Input) -> [BigBox] {
      switch direction {
      case .up:
        let directlyUp = self.advancedBy(.up)
        return [directlyUp, directlyUp.advancedBy(.left), directlyUp.advancedBy(.right)]
      case .right:
        let directlyRight = self.advancedBy(.right).advancedBy(.right)
        return [directlyRight]  //, directlyRight.advancedBy(.up), directlyRight.advancedBy(.down)]
      case .left:
        let directlyLeft = self.advancedBy(.left).advancedBy(.left)
        return [directlyLeft]  //, directlyLeft.advancedBy(.up), directlyLeft.advancedBy(.down)]
      case .down:
        let directlyDown = self.advancedBy(.down)
        return [directlyDown, directlyDown.advancedBy(.left), directlyDown.advancedBy(.right)]
      }
    }

    public func isTouchingWall(walls: Set<Position>, in direction: Input) -> Bool {
      return walls.contains(left.advancedBy(direction))
        || walls.contains(right.advancedBy(direction))
    }
  }

  struct Board {
    var walls: Set<Position>
    var boxes: Set<Position>

    var bigBoxes: Set<BigBox>
  }

  enum Input: Character {
    case up = "^"
    case left = "<"
    case right = ">"
    case down = "v"
  }

  func bigInput(input: String) -> String {
    return
      input
      .replacingOccurrences(of: ".", with: "..")
      .replacingOccurrences(of: "#", with: "##")
      .replacingOccurrences(of: "O", with: "[]")
      .replacingOccurrences(of: "@", with: "@.")
  }

  // board, starting position, inputs
  func parsedInput(input: String) -> (Board, Position, [Input]) {
    let splitData = input.split(separator: "\n\n")

    let map = splitData[0]
    let inputs = splitData[1]

    let mappedInputs =
      inputs
      .components(separatedBy: .whitespacesAndNewlines)
      .joined()
      .compactMap {
        Input(rawValue: $0)
      }

    var walls: Set<Position> = []
    var boxes: Set<Position> = []
    var bigBoxes: Set<BigBox> = []

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
        } else if character == "[" {
          let bigBox = BigBox(
            left: Position(row: rowIndex, column: columnIndex),
            right: Position(row: rowIndex, column: columnIndex + 1)
          )

          bigBoxes.insert(bigBox)
        }
      }
    }

    return (
      Board(
        walls: walls,
        boxes: boxes,
        bigBoxes: bigBoxes
      ),
      startingPosition,
      mappedInputs
    )
  }

  func part1() -> Any {
    let (board, startingPosition, inputs) = parsedInput(input: data)

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

      let boxesChain = boxes.chainOfBoxes(
        startingAt: nextPotentialPosition, direction: currentInput)
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
    let parsedInput = parsedInput(input: bigInput(input: data))

    let (board, startingPosition, inputs) = parsedInput

    let walls = board.walls
    var bigBoxes = board.bigBoxes

    var inputsToProcess: Deque<Input> = .init(inputs)
    var currentPosition: Position = startingPosition

    while let currentInput = inputsToProcess.popFirst() {
      let nextPotentialPosition = currentPosition.advancedBy(currentInput)

      let isWall = walls.contains(nextPotentialPosition)
      guard !isWall else {
        // Nothing we can do if it's a wall.
        continue
      }

      let boxesImPotentiallyTouching: [Position] =
        switch currentInput {
        // If it's to the left, then I'm touching the right side of it, so advanced by one more step.
        case .left:
          [nextPotentialPosition.advancedBy(.left)]
        case .right:
          // If it's to the right, then I'm standing right next to it:
          [nextPotentialPosition]
        case .up, .down:
          // And if it's above or below, then it's either directly above me, or to the left.
          [nextPotentialPosition, nextPotentialPosition.advancedBy(.left)]
        }

      let boxesImActuallyTouching =
        boxesImPotentiallyTouching
        .map {
          BigBox(
            left: $0,
            right: $0.advancedBy(.right)
          )
        }
        .filter {
          bigBoxes.contains($0)
        }

      // If I'm not touching any boxes, just move
      guard !boxesImActuallyTouching.isEmpty else {
        currentPosition = nextPotentialPosition
        continue
      }

      guard boxesImActuallyTouching.count == 1 else {
        fatalError("whoops?")
      }

      // now, we need to check if the chain of boxes starting from that position can be moved
      do {

        let chainOfBoxes = try bigBoxes.chainOfBoxes(
          startingAt: boxesImActuallyTouching.first!,
          direction: currentInput,
          walls: walls
        )

        let newBoxes = chainOfBoxes.map { $0.advancedBy(currentInput) }

        for oldBox in chainOfBoxes {
          bigBoxes.remove(oldBox)
        }

        for newBox in newBoxes {
          bigBoxes.insert(newBox)
        }

        currentPosition = nextPotentialPosition

      } catch {
        // If we can't move the box, we ignore the input.
        continue
      }
    }

    let score = bigBoxes.map { $0.left.row * 100 + $0.left.column }

    return score.reduce(0, +)
  }
}

extension Set<Day15.Position> {
  func chainOfBoxes(startingAt startPosition: Day15.Position, direction: Day15.Input) -> [Day15
    .Position]
  {
    var boxes: [Day15.Position] = [startPosition]

    var nextPosition: Day15.Position? = startPosition.advancedBy(direction)

    while let innerNextPosition = nextPosition, self.contains(innerNextPosition) {
      boxes.append(innerNextPosition)

      nextPosition = innerNextPosition.advancedBy(direction)
    }

    return boxes
  }
}

extension Set<Day15.BigBox> {
  func chainOfBoxes(
    startingAt startPosition: Day15.BigBox, direction: Day15.Input, walls: Set<Day15.Position>
  ) throws -> [Day15.BigBox] {
    guard !startPosition.isTouchingWall(walls: walls, in: direction) else {
      throw BoxMoving.cannotMoveBox
    }

    var boxes: [Day15.BigBox] = [startPosition]

    var nextPositions: Deque<Day15.BigBox> = [startPosition]

    while let innerNextPosition = nextPositions.popFirst() {
      let touchingBoxes =
        innerNextPosition
        .potentiallyTouchingBoxes(in: direction)
        .filter { self.contains($0) }

      guard touchingBoxes.allSatisfy({ !$0.isTouchingWall(walls: walls, in: direction) }) else {
        // If any of the potential touching boxes exist, and are touching walls, we cannot move the whole chain, so we throw
        // an error.
        throw BoxMoving.cannotMoveBox
      }

      // If none of the boxes touch the wall, we check if _they_ touch any walls that can be moved.
      nextPositions.prepend(contentsOf: touchingBoxes)
      boxes.append(contentsOf: touchingBoxes)
    }

    return boxes
  }
}

enum BoxMoving: Error {
  case cannotMoveBox
}

extension Day15.Board {
  func visualize(currentPosition: Day15.Position) -> String {
    let rows = self.walls.sorted(by: { $0.row < $1.row }).last!.row
    let columns = self.walls.sorted(by: { $0.column < $1.column }).last!.column

    var matrix = Array(repeating: Array(repeating: ".", count: columns + 1), count: rows + 1)
    for bigBox in self.bigBoxes {
      matrix[bigBox.left.row][bigBox.left.column] = "["
      matrix[bigBox.right.row][bigBox.right.column] = "]"
    }

    for wall in self.walls {
      matrix[wall.row][wall.column] = "#"
    }

    matrix[currentPosition.row][currentPosition.column] = "@"

    return matrix.map {
      $0.joined()
    }.joined(separator: "\n")
  }
}
