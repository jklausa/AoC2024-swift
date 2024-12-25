import Algorithms

struct Day25: AdventDay {
  var data: String

  struct Lock {
    let pinHeight1: Int
    let pinHeight2: Int
    let pinHeight3: Int
    let pinHeight4: Int
    let pinHeight5: Int

    init(keyString: [String]) {
      self.pinHeight1 = charactersAtColumn(column: 0, from: keyString).filter { $0 == "#" }.count
      self.pinHeight2 = charactersAtColumn(column: 1, from: keyString).filter { $0 == "#" }.count
      self.pinHeight3 = charactersAtColumn(column: 2, from: keyString).filter { $0 == "#" }.count
      self.pinHeight4 = charactersAtColumn(column: 3, from: keyString).filter { $0 == "#" }.count
      self.pinHeight5 = charactersAtColumn(column: 4, from: keyString).filter { $0 == "#" }.count
    }
  }

  struct Key {
    let pinHeight1: Int
    let pinHeight2: Int
    let pinHeight3: Int
    let pinHeight4: Int
    let pinHeight5: Int

    init(keyString: [String]) {
      self.pinHeight1 = charactersAtColumn(column: 0, from: keyString).filter { $0 == "#" }.count
      self.pinHeight2 = charactersAtColumn(column: 1, from: keyString).filter { $0 == "#" }.count
      self.pinHeight3 = charactersAtColumn(column: 2, from: keyString).filter { $0 == "#" }.count
      self.pinHeight4 = charactersAtColumn(column: 3, from: keyString).filter { $0 == "#" }.count
      self.pinHeight5 = charactersAtColumn(column: 4, from: keyString).filter { $0 == "#" }.count
    }

    func matches(lock: Lock) -> Bool {
      let matchingPins = [
        doesPin(pinHeight1, matchLockPin: lock.pinHeight1),
        doesPin(pinHeight2, matchLockPin: lock.pinHeight2),
        doesPin(pinHeight3, matchLockPin: lock.pinHeight3),
        doesPin(pinHeight4, matchLockPin: lock.pinHeight4),
        doesPin(pinHeight5, matchLockPin: lock.pinHeight5)
      ]

      return matchingPins.allSatisfy { $0 == true }
    }

    private func doesPin(_ pin: Int, matchLockPin lockPin: Int) -> Bool {
      switch lockPin {
      case 0:
        return true
      case 1:
        return pin <= 4
      case 2:
        return pin <= 3
      case 3:
        return pin <= 2
      case 4:
        return pin <= 1
      case 5:
        return pin == 0
      default:
        return false
      }
    }
  }

  static func charactersAtColumn(column: Int, from keyString: [String]) -> [Character] {
    keyString.map { $0[$0.index($0.startIndex, offsetBy: column)] }
  }


  var entities: ([Key], [Lock]) {
    let entries = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n\n")

    var keys: [Key] = []
    var locks: [Lock] = []

    for entity in entries {
      let lines = entity.split(separator: "\n")

      if lines.first?.first == "#" {
        locks.append(
          Lock(
            keyString: lines
              .dropFirst()
              .dropLast()
              .map { String($0) }
          )
        )
      } else {
        keys.append(
          Key(
            keyString: lines
              .dropFirst()
              .dropLast()
              .map { String($0) })
        )
      }
    }

    return (keys, locks)
  }

  func part1() -> Any {
    let (keys, locks) = entities

    var matchingCombinations = 0

    for key in keys {
      for lock in locks {
        if key.matches(lock: lock) {
          matchingCombinations += 1
        }
      }
    }

    return matchingCombinations
  }

}
