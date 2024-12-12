import Testing

@testable import AdventOfCode

struct Day12ests {
  let testDataOne = """
AAAA
BBCD
BBCC
EEEC
"""

  let testDataTwo = """
OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
"""

  let testDataThree = """
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"""

  @Test func testPart1() async throws {
    let challenge = Day12(data: testDataOne)
    #expect(String(describing: challenge.part1()) == "140")

    let challenge2 = Day12(data: testDataTwo)
    #expect(String(describing: challenge2.part1()) == "772")

    let challenge3 = Day12(data: testDataThree)
    #expect(String(describing: challenge3.part1()) == "1930")
  }

}
