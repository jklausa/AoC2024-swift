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

      output.append(digits[0..<(digits.count / 2)].numberFromDigits)
      output.append(digits[(digits.count / 2)..<digits.count].numberFromDigits)
    }

    return output
  }

  // number: count
  func processStonesSmarter(input: [Int: Int]) -> [Int: Int] {
    var result: [Int: Int] = [:]

    for (stone, count) in input {
      guard stone != 0 else {
        result[1, default: 0] += count
        continue
      }

      guard stone != 1 else {
        result[2024, default: 0] += count
        continue
      }

      let digits = stone.digits
      guard digits.count % 2 == 0 else {
        result[stone * 2024, default: 0] += count
        continue
      }

      let left = digits[0..<(digits.count / 2)].numberFromDigits
      let right = digits[(digits.count / 2)..<digits.count].numberFromDigits

      result[left, default: 0] += count
      result[right, default: 0] += count
    }

    return result
  }

  func recursiveProcessStones(number: Int, recursion: Int, memo: inout [Int: [Int: Int]]) -> Int {
    guard recursion != 0 else { return 1 }

    if let result = memo[recursion]?[number] {
      return result
    }

    if number == 0 {
      let result = recursiveProcessStones(number: 1, recursion: recursion - 1, memo: &memo)
      memo[recursion, default: [:]][number] = result
      return result
    }

    if number == 1 {
      let result = recursiveProcessStones(number: 2024, recursion: recursion - 1, memo: &memo)
      memo[recursion, default: [:]][number] = result
      return result
    }

    let digits = number.digits
    guard digits.count % 2 == 0 else {
      let result = recursiveProcessStones(
        number: number * 2024, recursion: recursion - 1, memo: &memo)
      memo[recursion, default: [:]][number] = result

      return result
    }

    let left = digits[0..<(digits.count / 2)].numberFromDigits
    let right = digits[(digits.count / 2)..<digits.count].numberFromDigits

    let leftResult = recursiveProcessStones(number: left, recursion: recursion - 1, memo: &memo)
    let rightResult = recursiveProcessStones(number: right, recursion: recursion - 1, memo: &memo)

    memo[recursion, default: [:]][number] = leftResult + rightResult

    return leftResult + rightResult
  }

  func part1() -> Any {
    var stones = initialStones

    for _ in 1...25 {
      stones = processStones(input: stones)
    }

    return stones.count
  }

  func part2() -> Any {
    var memo: [Int: [Int: Int]] = [:]

    let recursive = initialStones.map {
      recursiveProcessStones(number: $0, recursion: 75, memo: &memo)
    }.reduce(0, +)

    return recursive
  }

  func alternativePart2() -> Any {
    var stones = initialStones.reduce(into: [:]) { $0[$1, default: 0] += 1 }

    for _ in 1...75 {
      stones = processStonesSmarter(input: stones)
    }

    let sum = stones.reduce(into: 0) { acc, dictionaryItem in
      acc += dictionaryItem.value
    }

    return sum
  }
}

extension Int {
  fileprivate var digits: [Int] {
    var num = self
    var digits: [Int] = []

    while num > 0 {
      digits.insert(num % 10, at: 0)
      num /= 10
    }

    return digits.isEmpty ? [0] : digits
  }
}

extension ArraySlice<Int> {
  fileprivate var numberFromDigits: Int {
    reduce(0) { $0 * 10 + $1 }
  }
}
