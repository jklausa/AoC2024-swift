import Algorithms
import Foundation

struct Day19: AdventDay {
  var data: String

  struct Towel: Hashable {
    let stripes: String
  }

  struct ExpectedTowelChain: Hashable {
    let chain: String
  }

  var entities: ([Towel], [ExpectedTowelChain]) {
    let splitData = data
      .components(separatedBy: "\n\n")

    let availableTowels = splitData
      .first?
      .components(separatedBy: ",")
      .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { Towel(stripes: $0) } ?? []

    let expectedTowelChains = splitData
      .last?
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: .newlines)
      .compactMap { ExpectedTowelChain(chain: $0) } ?? []

    return (availableTowels, expectedTowelChains)
  }

  func canBeArranged(towels: [Towel],
                     chain: ExpectedTowelChain,
                     solvableChains: Set<ExpectedTowelChain>) -> Bool {
    var chainVariants: Deque<ExpectedTowelChain> = [chain]
        var checkedChains: Set<ExpectedTowelChain> = []

    while let currentChain = chainVariants.popFirst() {
      guard !solvableChains.contains(currentChain) else {
        return true
      }

      checkedChains.insert(currentChain)

      for availableTowel in towels {
        guard currentChain.chain.hasPrefix(availableTowel.stripes) else {
          continue
        }

        let newString = String(currentChain.chain.dropFirst(availableTowel.stripes.count))

        guard !newString.isEmpty else {
          return true
        }

        let newChain = ExpectedTowelChain(chain: newString)

        guard !checkedChains.contains(newChain) else {
          continue
        }

        chainVariants.prepend(newChain)
      }
    }

    return false
  }

  func part1() -> Any {
    var answer = 0
    var solvableTowels: Set<ExpectedTowelChain> = []

    let availableTowels = entities.0
    let expectedTowelChains = entities.1


    for (index, towel) in expectedTowelChains.enumerated() {
      let canBeSolved = canBeArranged(towels: availableTowels, chain: towel, solvableChains: solvableTowels)
      if canBeSolved {
        answer += 1
      }
    }

    return answer
  }

  func part2() -> Any {
    return 0
//    entities.map { $0.max() ?? 0 }.reduce(0, +)
  }
}
