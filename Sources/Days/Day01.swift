struct Day01: AdventDay {
  var data: String

  var lines: [[String]] {
      return data
      .components(separatedBy: .newlines)
      .map { $0.components(separatedBy: .whitespaces) }
  }

  var left: [Int] {
    lines.compactMap { $0.first }.compactMap { Int($0) }
  }

  var right: [Int] {
    lines.compactMap { $0.last }.compactMap { Int($0) }
  }

  func part1() -> Any {
    return zip(left.sorted(), right.sorted())
      .reduce(0, { $0 + (max($1.0, $1.1) - min($1.0, $1.1)) })
  }

  func part2() -> Any {
    let rightOccurenceMap = right.reduce(into: [0: 0]) { acc, number in
      acc[number, default: 0] += 1
    }

    let secondAnswer = left
      .map {
        $0 * rightOccurenceMap[$0, default: 0]
      }
      .reduce(0, +)

    return secondAnswer
  }

}
