import Algorithms

struct Day16: AdventDay {
  var data: String

  enum Direction: Hashable {
    case up
    case down
    case left
    case right

    var validNextDirections: [Direction] {
      switch self {
      case .up, .down: return [.left, .right]
      case .left, .right: return [.up, .down]
      }
    }
  }

  struct CurrentPosition: Hashable {
    let position: Position
    let orientation: Direction

    var nextPosition: Position {
      position.advancedBy(orientation)
    }

    var nextPositionsIfRotating: [Position] {
      orientation.validNextDirections.map { position.advancedBy($0) }
    }
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

    func isWall(in map: [[MapTile]]) -> Bool {
      map[row][column] == .obstacle
    }
  }

  struct Path: Hashable {
    var turns: Int
    var tilesWalked: Set<Position>

    var currentPosition: CurrentPosition

    var price: Int {
      tilesWalked.count + turns * 1000
    }
  }

  enum MapTile: Hashable {
    case path
    case obstacle
    case destination
    case startPoint

//    case currentPosition(CurrentPosition)

    init?(character: Character) {
      switch character {
      case ".": self =  .path
      case "#": self = .obstacle
      case "E": self = .destination
      case "S": self = .startPoint
      default: return nil
      }
    }

//    var stringRepresentation: String {
//      switch self {
//
//      }
//    }
  }

  var parsedMap: [[MapTile]] {
    let rows = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .filter { !$0.isEmpty }

    return rows.map {
      let columns = $0.map { $0 }

      return columns.compactMap { character in
        MapTile(character: character)
      }
    }
  }

  func part1() -> Any {
    let map = parsedMap

    var completePaths: [Path] = []

    let startingPosition = Position(row: map.indices.last! - 1,
                                    column: 1)

    var pathsToCheck: Deque<Path> = [
      .init(
        turns: 0,
        tilesWalked: [],
        currentPosition:
            .init(
              position: startingPosition,
              orientation: .right
            )
      )
    ]

    var prices: [Position: Int] = [:]

    while let path = pathsToCheck.popFirst() {
      guard map[path.currentPosition.position] != .destination else {
        completePaths.append(path)
        continue
      }

      let currentPrice = prices[path.currentPosition.position, default: Int.max]
      guard path.price < currentPrice else {
        continue
      }

      prices[path.currentPosition.position] = path.price


      // We don't wanna double-over on the same tile
      guard !path.tilesWalked.contains(path.currentPosition.position) else {
        continue
      }

      let nextPosition = path.currentPosition.nextPosition
      // If we can walk forward, let's just try that.
      if !nextPosition.isWall(in: map) {
        var newPath = path
        newPath.tilesWalked.insert(path.currentPosition.position)
        newPath.currentPosition = .init(position: nextPosition,
                                        orientation: path.currentPosition.orientation)

        pathsToCheck.append(newPath)
      }

      let rotatedPositions = path
        .currentPosition
        .orientation
        .validNextDirections

      for newDirection in rotatedPositions {
        let rotatedPosition = path.currentPosition.position.advancedBy(newDirection)
        if !rotatedPosition.isWall(in: map) {
          var newPath = path
          newPath.turns += 1
          newPath.tilesWalked.insert(path.currentPosition.position)
          newPath.currentPosition = .init(position: rotatedPosition,
                                          orientation: newDirection)

          pathsToCheck.append(newPath)
        }
      }
    }

    let scores = completePaths
      .map {
        $0.price
      }
      .sorted()

//    print(completePaths)


    return scores.first!
  }

//  func part2() -> Any {
//    entities.map { $0.max() ?? 0 }.reduce(0, +)
//  }

//  func printMap(map mapToPrint: [[MapTile]], currentPosition: CurrentPosition) -> String {
//    var mapToPrint = mapToPrint
//    mapToPrint[currentPosition.position.row][currentPosition.position.column] = .
//  }
}

fileprivate extension Array<[Day16.MapTile]> {
  subscript(position: Day16.Position) -> Day16.MapTile {
    self[position.row][position.column]
  }
}
