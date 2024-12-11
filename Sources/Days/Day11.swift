import Algorithms
import Foundation

struct Day11: AdventDay {
  var data: String

  var initialStones: [Int] {
    data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .whitespaces)
      .compactMap { Int(String($0)) }
  }

  // naive, brute-force
  func processStones(input: any Sequence<Int>) -> [Int] {
    var output: [Int] = []

    for stone in input {
      guard stone != 0 else {
        output.append(1)
        continue
      }

      let digits = stone.digits
      guard digits.count % 2 == 0 else {
        output.append(stone * 2024)
        continue
      }


      output.append(digits[0 ..< (digits.count / 2)].numberFromDigits)
      output.append(digits[(digits.count / 2) ..< digits.count].numberFromDigits)
    }

    return output
  }

  func part1() async -> Any {
    var stones = initialStones

    for _ in 1 ... 25 {
      stones = processStones(input: stones)
    }

    return stones.count
  }

  func part2() async -> Any {
    return 0
  }
}

fileprivate extension Int {
  var digits: [Int] {
    var num = self
    var digits: [Int] = []

    while num > 0 {
      digits.insert(num % 10, at: 0)
      num /= 10
    }

    return digits.isEmpty ? [0] : digits
  }
}

fileprivate extension ArraySlice<Int> {
  var numberFromDigits: Int {
    reduce(0) { $0 * 10 + $1 }
  }
}
