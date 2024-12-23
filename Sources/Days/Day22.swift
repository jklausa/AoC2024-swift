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

  struct Price {
    var price: Int
    var change: Int?
  }

  struct Pattern: Hashable {
    var num1: Int
    var num2: Int
    var num3: Int
    var num4: Int
  }

  private func valueFor(priceList: [Price], with pattern: Pattern) -> Int? {
    for i in 0..<priceList.count - 4 {
      guard pattern.num1 == priceList[i].change,
            pattern.num2 == priceList[i+1].change,
            pattern.num3 == priceList[i+2].change,
            pattern.num4 == priceList[i+3].change else {
        continue
      }

      return priceList[i+3].price
    }

    return nil
  }

  func part2() -> Any {
    let initialSecrets = entities

    let after2000Rounds = initialSecrets.map {
      var values: [Price] = []
      var tmp = $0

      for _ in 0..<2000 {
        tmp = firstRule(currentNumber: tmp)
        tmp = secondRule(currentNumber: tmp)
        tmp = thirdRule(currentNumber: tmp)

        if let last = values.last {
          values.append(Price(price: tmp % 10, change: tmp % 10 - last.price))
        } else {
          values.append(Price(price: tmp % 10))
        }
      }

      return values
    }

    var patterns: Set<Pattern> = []

    for value in after2000Rounds {
      for i in 4..<value.count {
        let pattern = Pattern(num1: value[i-3].change!,
                              num2: value[i-2].change!,
                              num3: value[i-1].change!,
                              num4: value[i].change!)

        patterns.insert(pattern)
      }
    }

    var maxOutcome = Int.min

    for currentPattern in patterns {
      var currentPatternValue = 0

      for pricesList in after2000Rounds {
        if let value = valueFor(priceList: pricesList, with: currentPattern) {
          currentPatternValue += value
        }
      }

      maxOutcome = max(maxOutcome, currentPatternValue)
    }

    return maxOutcome
  }
}
