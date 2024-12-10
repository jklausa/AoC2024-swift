struct Day05: AdventDay {
  var data: String

  var entities: [[Int]] {
    data.split(separator: "\n\n").map {
      $0.split(separator: "\n").compactMap { Int($0) }
    }
  }

  var rules: [String] {
    data
      .split(separator: "\n\n")[0]
      .components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
  }

  var pages: [[Int]] {
    data
      .split(separator: "\n\n")[1]
      .components(separatedBy: .newlines)
      .filter { !$0.isEmpty }
      .map { string in string.components(separatedBy: ",") }
      .map { string in string.map { Int(String($0))! } }
  }

  func part1() -> Any {
    var mustBeFollowedBy: [Int: Set<Int>] = [:]

    for rule in rules {
      let components = rule.split(separator: "|").compactMap { Int(String($0)) }

      let first = components[0]
      let second = components[1]

      mustBeFollowedBy[first, default: []].insert(second)
    }

    var validLists: [[Int]] = []
    for update in pages {
      var seenNumbers: Set<Int> = []

      var hasFoundViolation: Bool = false
      for number in update {
        if let followingRule = mustBeFollowedBy[number] {
          let breaksRule = !seenNumbers.intersection(followingRule).isEmpty

          if breaksRule {
            hasFoundViolation = true
            break
          }
        }

        seenNumbers.insert(number)
      }

      if !hasFoundViolation {
        validLists.append(update)
      }
    }

    return validLists.reduce(into: 0) { acc, list in
      acc += list[list.count / 2]
    }
  }

  func part2() -> Any {
    var mustBeFollowedBy: [Int: Set<Int>] = [:]

    for rule in rules {
      let components = rule.split(separator: "|").compactMap { Int(String($0)) }

      let first = components[0]
      let second = components[1]

      mustBeFollowedBy[first, default: []].insert(second)
    }

    var inValidLists: [[Int]] = []
    for update in pages {
      var seenNumbers: Set<Int> = []

      for number in update {
        if let followingRule = mustBeFollowedBy[number] {
          let breaksRule = !seenNumbers.intersection(followingRule).isEmpty

          if breaksRule {
            inValidLists.append(update)
            break
          }
        }
        seenNumbers.insert(number)
      }
    }

    var sorted: [[Int]] = []
    for inValidList in inValidLists {
      sorted.append(
        inValidList.sorted {
          // first argument should be before last
          if let set = mustBeFollowedBy[$0],
            set.contains($1)
          {
            return false
          }

          return true
        })
    }

    return sorted.reduce(into: 0) { acc, list in
      acc += list[list.count / 2]
    }
  }
}
