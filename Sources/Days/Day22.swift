import Algorithms

struct Day22: AdventDay {
  var data: String

  var entities: [Int] {
    data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .compactMap {
        Int($0)
      }
  }

  @inlinable
  func firstRule(currentNumber: Int) -> Int {
    (currentNumber ^ currentNumber << 6) & 16777215
  }


  func secondRule(currentNumber: Int) -> Int {
    (currentNumber >> 5 ^ currentNumber) & 16777215
  }

  func thirdRule(currentNumber: Int) -> Int {
    (currentNumber << 11 ^ currentNumber) & 16777215
  }

  func part1() -> Any {
    let initialSecrets = entities

    let after2000Rounds = initialSecrets.map {
      var tmp = $0
      for _ in 0..<2000 {
        tmp = firstRule(currentNumber: tmp)
        tmp = secondRule(currentNumber: tmp)
        tmp =  thirdRule(currentNumber: tmp)
      }
      return tmp
    }

    return after2000Rounds.reduce(0, +)
  }

//  func part2() -> Any {
//    entities.map { $0.max() ?? 0 }.reduce(0, +)
//  }
}
