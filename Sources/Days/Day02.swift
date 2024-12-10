struct Day02: AdventDay {
  var data: String

  var levels: [[Int]] {
    data
      .components(separatedBy: .newlines)
      .map { $0.components(separatedBy: .whitespaces) }
      .map { $0.compactMap { Int($0) } }
      .filter { !$0.isEmpty }
  }

  func isValid(level: [Int]) -> Bool {
    var signum: Int? = nil

    for (idx, current) in level.enumerated() {
      guard idx != 0 else { continue }

      let previous = level[idx - 1]
      let difference = (current - previous)

      if abs(difference) < 1 || abs(difference) > 3 {
        return false
      }

      if let currentSignum = signum {
        if currentSignum != difference.signum() {
          return false
        }
      }

      signum = difference.signum()
    }

    return true
  }

  func isValidWithTolerance(level: [Int], isCheckingVariant: Bool = false) -> Bool {
    var potentialIndexes: Set<Int> = []
    var signum: Int? = nil

    for (idx, current) in level.enumerated() {
      guard idx != 0 else { continue }

      let previous = level[idx - 1]
      let difference = (current - previous)

      if abs(difference) < 1 || abs(difference) > 3 {
        potentialIndexes.insert(idx)
        potentialIndexes.insert(idx - 1)
      }

      if let currentSignum = signum {
        if currentSignum != difference.signum() {
          potentialIndexes.insert(idx)
          potentialIndexes.insert(idx - 2)
        }
      }

      signum = difference.signum()
    }

    if !isCheckingVariant {
      for potentialIndex in potentialIndexes {
        guard level.indices.contains(potentialIndex) else { continue }

        let levelWithoutIndex = {
          var tmp = level
          tmp.remove(at: potentialIndex)
          return tmp
        }()

        let result = isValidWithTolerance(level: levelWithoutIndex, isCheckingVariant: true)
        if result {
          return true
        }
      }
    }

    return potentialIndexes.isEmpty
  }

  func part1() -> Any {
    return levels
      .filter(isValid(level:))
      .count
  }

  func part2() -> Any {
    return levels
      .filter { isValidWithTolerance(level: $0) }
      .count
  }
}
