import Algorithms

struct Day20: AdventDay {
  var data: String

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

  enum Direction: Hashable, CaseIterable {
    case up
    case down
    case left
    case right
  }

  struct Position: Hashable {
    var row: Int
    var column: Int

    public func advancedBy(_ input: Direction) -> Position {
      switch input {
      case .up: return Position(row: row - 1, column: column)
      case .left: return Position(row: row, column: column - 1)
      case .right: return Position(row: row, column: column + 1)
      case .down: return Position(row: row + 1, column: column)
      }
    }

    func isWall(in map: [[MapTile]]) -> Bool {
      guard row >= 0, column >= 0 else {
        return true
      }

      guard row < map.count, column < map[row].count else {
        return true
      }

      return map[row][column] == .obstacle
    }

    func canBeWarpedThrough(in direction: Direction, map: [[MapTile]]) -> Bool {
      let isCurrentlyAWall = isWall(in: map)
      let isNextNotAWall = self.advancedBy(direction).isWall(in: map)

      return isCurrentlyAWall && !isNextNotAWall
    }
  }

  enum MapTile: Hashable {
    case path
    case obstacle
    case destination
    case startPoint

    init?(character: Character) {
      switch character {
      case ".": self =  .path
      case "#": self = .obstacle
      case "E": self = .destination
      case "S": self = .startPoint
      default: return nil
      }
    }
  }

  func findShortestPath(map: [[MapTile]],
                        startingPoint: Position,
                        destination: Position) -> Int {
    var pathsToCheck: Deque<Position> = [startingPoint]
    var length: [Position: Int] = [startingPoint: 0]

    while let currentPath = pathsToCheck.popFirst() {
      guard currentPath != destination else {
        continue
      }

      let validNextSteps = Direction
        .allCases
        .map { currentPath.advancedBy($0) }
        .filter { !$0.isWall(in: map)}

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
    let map = parsedMap
    var startingPosition: Position = .init(row: 0, column: 0)
    var destinationPosition: Position = .init(row: 0, column: 0)
    var walls: [Position] = []

    for row in map.indices {
      for (column, tile) in map[row].enumerated() {
        if tile == .startPoint {
          startingPosition = .init(row: row, column: column)
        }

        if tile == .destination {
          destinationPosition = .init(row: row, column: column)
        }

        if tile == .obstacle {
          walls.append(.init(row: row, column: column))
        }
      }
    }

    let shortestPath = findShortestPath(map: map,
                                        startingPoint: startingPosition,
                                        destination: destinationPosition)

    let viableWallSkips = walls.filter { wall in
      let skipViability = Direction.allCases.map {
        wall.canBeWarpedThrough(in: $0, map: map)
      }

      return skipViability.first { $0 == true } != nil
    }

    var shortcutsLenghts: [Int] = []

    for  wallSkip in viableWallSkips {

      var mapCopy = map
      mapCopy[wallSkip.row][wallSkip.column] = .path
      let newShortest = findShortestPath(map: mapCopy,
                                         startingPoint: startingPosition,
                                         destination: destinationPosition)

      shortcutsLenghts.append(newShortest)
    }

    let savingMoreThan100 = shortcutsLenghts
      .filter { $0 <= shortestPath - 100 }
      .count

    return savingMoreThan100
  }

  func part2() -> Any {
    return 0
  }
}
