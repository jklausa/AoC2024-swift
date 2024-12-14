struct Day14: AdventDay {
  var data: String

  struct Position: Hashable {
    let x: Int
    let y: Int
  }
  // assuming origin at top left

  struct Input {
    let startingPosition: Position
    let movement: (Int, Int)
  }

  var inputs: [Input] {
    let lines = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .filter { !$0.isEmpty }

    let regex = /p=(-?\d+)\,(-?\d+) v=(-?\d+)\,(-?\d+)/


    return lines.compactMap {
      guard let match = try? regex.firstMatch(in: $0) else {
        return nil
      }

      return Input(
        startingPosition: Position(
          x: Int(match.output.1)!,
          y: Int(match.output.2)!),
        movement: (
          Int(match.output.3)!,
          Int(match.output.4)!
        )
      )
    }
  }

  func calculatePosition(for input: Input, after seconds: Int, gridSize: (Int, Int)) -> Position {
    let (dx, dy) = input.movement

    let newPosition = (input.startingPosition.x + dx * seconds,
                       input.startingPosition.y + dy * seconds)

    return Position(x: newPosition.0 %% gridSize.0,
                    y: newPosition.1 %% gridSize.1)
  }

  func part1() -> Any {
    let parsedInputs = inputs
    let gridSize = (101, 103)

    let movedItems = parsedInputs.map {
      calculatePosition(for: $0, after: 100, gridSize: gridSize)
    }

    let grid = movedItems.reduce(into: [Position: Int]()) {
      $0[$1, default: 0] += 1
    }

    let middleColumn = (gridSize.0 - 1) / 2
    let middleRow = (gridSize.1 - 1) / 2

    var topLeftCount = 0
    var topRightCount = 0
    var bottomLeftCount = 0
    var bottomRightCount = 0

    for (position, count) in grid {
      if position.x < middleColumn {
        if position.y < middleRow {
          topLeftCount += count
        } else if position.y > middleRow {
          bottomLeftCount += count
        }
      } else if position.x > middleColumn {
        if position.y < middleRow {
          topRightCount += count
        } else if position.y > middleRow {
          bottomRightCount += count
        }
      }
    }

    return topLeftCount * topRightCount * bottomLeftCount * bottomRightCount
  }

  func part2() -> Any {
    return 0
  }
}


infix operator %%

extension Int {

  static  func %% (_ left: Int, _ right: Int) -> Int {
    let mod = left % right
    return mod >= 0 ? mod : mod + right
  }

}
