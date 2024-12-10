struct Day04: AdventDay {
  var data: String

  var lines: [String] {
      data.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
  }

  func isArrayOfCharactersMatching(_ characters: [Character], string: String) -> Bool {
    let charactersString = String(characters)

    if charactersString == string ||  String(characters.reversed()) == string {
      return true
    }

    return false
  }

  func part1() -> Any {
    var count = 0
    for row in lines.indices {
      let currentRow = lines[row]

      // Let's do the easy ones first.
      count += currentRow.matches(of: /XMAS/).count
      count += currentRow.matches(of: /SAMX/).count

      if lines.indices ~= row - 3 {
        let rowMinus3 = lines[row - 3]
        let rowMinus2 = lines[row - 2]
        let rowMinus1 = lines[row - 1]

        // We can check the diagonals and verticals now.

        let matrix = [
          rowMinus3.map(Character.init),
          rowMinus2.map(Character.init),
          rowMinus1.map(Character.init),
          currentRow.map(Character.init)
        ]

        for index in matrix[3].indices {
          // X
          //   M
          //     A
          //       S
          if index >= 3 {
            let slash = [
              matrix[0][index - 3],
              matrix[1][index - 2],
              matrix[2][index - 1],
              matrix[3][index],
            ]

            if isArrayOfCharactersMatching(slash, string: "XMAS") {
              count += 1
            }
          }

          //       S
          //     A
          //   M
          // X
          if matrix[3].indices.contains(index + 3) {
            let backSlash = [
              matrix[0][index + 3],
              matrix[1][index + 2],
              matrix[2][index + 1],
              matrix[3][index],
            ]

            if isArrayOfCharactersMatching(backSlash, string: "XMAS"){
              count += 1
            }
          }

          let vertical = matrix.map { $0[index] }
          if isArrayOfCharactersMatching(vertical, string: "XMAS") {
            count += 1
          }
        }
      }
    }

    return count
  }

  func part2() -> Any {
    var countPartTwo = 0
    let charMatrix = lines.map { $0.map(Character.init) }

    for rowIndex in 1...(charMatrix.count - 2) {
      let row = charMatrix[rowIndex]

      for characterIndex in 1...(row.count - 2) {
        let character = charMatrix[rowIndex][characterIndex]

        guard character == "A" else { continue }

        let topLeftDiagonal = [
          charMatrix[rowIndex - 1][characterIndex - 1],
          character,
          charMatrix[rowIndex + 1][characterIndex + 1]
        ]

        let topRightDiagonal = [
          charMatrix[rowIndex - 1][characterIndex + 1],
          character,
          charMatrix[rowIndex + 1][characterIndex - 1]
        ]

        if isArrayOfCharactersMatching(topLeftDiagonal, string: "MAS"),
           isArrayOfCharactersMatching(topRightDiagonal, string: "MAS") {
          countPartTwo += 1
        }
      }
    }

    return countPartTwo
  }
}
