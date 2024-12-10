import RegexBuilder

struct Day03: AdventDay {
  var data: String

  nonisolated(unsafe)
    private let readableRegex = Regex {
      "mul("
      Capture {
        OneOrMore(.digit)
      } transform: {
        Int($0)!
      }
      ","
      Capture {
        OneOrMore(.digit)
      } transform: {
        Int($0)!
      }
      ")"
    }

  func part1() -> Any {
    let readableMatches = data.matches(of: readableRegex)

    return readableMatches.reduce(into: 0) { acc, variable in
      let newValue = variable.output.1 * variable.output.2
      acc += newValue
    }
  }

  struct Match {
    let kind: Kind

    let startIndex: String.Index

    enum Kind {
      case number(Int)
      case enable
      case disable
    }
  }

  func part2() -> Any {
    let enableRegex = Regex {
      "do()"
    }

    let disableRegex = Regex {
      "don't()"
    }

    let enableMatches = data.matches(of: enableRegex)
    let disableMatches = data.matches(of: disableRegex)

    let readableMatches = data.matches(of: readableRegex)

    let stage2Matches = [
      readableMatches
        .map {
          Match(
            kind: .number($0.output.1 * $0.output.2),
            startIndex: $0.range.lowerBound
          )
        },
      enableMatches.map {
        Match(kind: .enable, startIndex: $0.range.lowerBound)
      },
      disableMatches.map {
        Match(kind: .disable, startIndex: $0.range.lowerBound)
      },
    ]
    .flatMap { $0 }
    .sorted { $0.startIndex < $1.startIndex }

    var acc: Int = 0
    var isEnabled: Bool = true

    for match in stage2Matches {
      switch match.kind {
      case .number(let value):
        acc += isEnabled ? value : 0
      case .disable:
        isEnabled = false
      case .enable:
        isEnabled = true
      }
    }

    return acc
  }
}
