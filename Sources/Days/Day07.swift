struct Day07: AdventDay {
  var data: String

  // target, numbers
  func parseEquations(input: String) -> [(Int, [Int])] {
    data
      .components(separatedBy: .newlines)
      .compactMap {
        let components = $0.components(separatedBy: ":")

        guard components.count == 2 else {
          return nil
        }

        let equationResult = Int(components[0])!
        let numbers = components[1].components(separatedBy: .whitespaces).compactMap { Int($0) }

        return (equationResult, numbers)
      }
  }

  func recursiveCanAddUpToTarget(_ numbers: [Int], _ target: Int, isP2: Bool = false) -> Bool {
    var currentStack = [numbers]

    while !currentStack.isEmpty {
      let currentArray = currentStack.removeLast()

      guard currentArray.count > 1 else {
        if currentArray.first == target {
          return true
        }

        continue
      }

      let first = currentArray[0]
      let second = currentArray[1]

      let arrayWithoutFirstTwo = Array(currentArray.dropFirst(2))

      let added = first + second
      if added <= target {
        var addedArray = arrayWithoutFirstTwo
        addedArray.insert(added, at: 0)
        currentStack.append(addedArray)
      }

      let multiplied = first * second
      if multiplied <= target {
        var multipliedArray = arrayWithoutFirstTwo
        multipliedArray.insert(multiplied, at: 0)
        currentStack.append(multipliedArray)
      }

      if isP2 {
        let concated = Int(String(first) + String(second))!
        if concated <= target {
          var concatedArray = arrayWithoutFirstTwo
          concatedArray.insert(concated, at: 0)
          currentStack.append(concatedArray)
        }
      }

    }

    return false
  }

  func part1() -> Any {
    parseEquations(input: data)
      .enumerated()
      .filter {
        return recursiveCanAddUpToTarget($0.1.1, $0.1.0)
      }
      .reduce(into: 0) { $0 += $1.1.0 }
  }

  func part2() -> Any {
    parseEquations(input: data)
      .enumerated()
      .filter {
        return recursiveCanAddUpToTarget($0.1.1, $0.1.0, isP2: true)
      }
      .reduce(into: 0) { $0 += $1.1.0 }
  }
}
