import Foundation

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
    let lines =
      data
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

    let newPosition = (
      input.startingPosition.x + dx * seconds,
      input.startingPosition.y + dy * seconds
    )

    return Position(
      x: newPosition.0 %% gridSize.0,
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
    // The code here is not... interesting?
    // I just generated a bunch of files that contain the output, wrote them
    // out to my homedir, and looked through them via quicklook.
    // Once I had _a_ tree, I just added a simple text search to find the _first_ one....
    // Putting the string I searched for would spoil part of the puzzle, so I'm not including it.
    // If I ever go through and want to find this again, _an_ instance of the tree
    // is found at iteration 5000932 (for my input, that is.)
    //
    // Because I sometimes run the --benchmarkOption,
    // if you actually want to create a bunch of files, change this to true.
    let doYouWantToSpamYourDisk = false

    guard doYouWantToSpamYourDisk else {
      return "Disabled."
    }

    let parsedInputs = inputs
    let gridSize = (101, 103)

    let tmpDirectory = URL(fileURLWithPath: "file:///Users/klausa/aoc-output/")

    for iteration in 0_000_000...5_001_000 {
      let movedItems = parsedInputs.map {
        calculatePosition(for: $0, after: iteration, gridSize: gridSize)
      }

      let grid = movedItems.reduce(into: [Position: Int]()) {
        $0[$1, default: 0] += 1
      }

      let row = Array(repeating: ".", count: 103)
      var visualizedArray = Array(repeating: row, count: 103)

      for newRobotPosition in grid {
        visualizedArray[newRobotPosition.key.y][newRobotPosition.key.x] = "#"
      }

      let tmpFileName = tmpDirectory.appendingPathComponent("\(iteration).txt")

      let strings =
        visualizedArray
        .map { currentRow in
          let joined = currentRow.joined()

          if joined.contains("STRING TO FIND A TREE HERE") {
            fatalError("Found it: \(iteration)")
          }

          return joined
        }
        .joined(separator: "\n")

      guard doYouWantToSpamYourDisk else { continue }

      try? strings.write(to: tmpFileName, atomically: true, encoding: .utf8)
    }

    return tmpDirectory
  }
}

infix operator %%
extension Int {
  static func %% (_ left: Int, _ right: Int) -> Int {
    let mod = left % right
    return mod >= 0 ? mod : mod + right
  }

}
