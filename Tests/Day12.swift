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

  let testDataFour = """
    EEEEE
    EXXXX
    EEEEE
    EXXXX
    EEEEE
    """

  let testDataFive = """
    AAAAAA
    AAABBA
    AAABBA
    ABBAAA
    ABBAAA
    AAAAAA
    """

  @Test func testPart1() async throws {
    let challenge = Day12(data: testDataOne)
    #expect(String(describing: challenge.part1()) == "140")

    let challenge2 = Day12(data: testDataTwo)
    #expect(String(describing: challenge2.part1()) == "772")

    let challenge3 = Day12(data: testDataThree)
    #expect(String(describing: challenge3.part1()) == "1930")
  }

  @Test func testPart2() async throws {
    let challenge = Day12(data: testDataOne)
    #expect(String(describing: challenge.part2()) == "80")

    let challenge2 = Day12(data: testDataTwo)
    #expect(String(describing: challenge2.part2()) == "436")

    let challenge3 = Day12(data: testDataThree)
    #expect(String(describing: challenge2.part2()) == "1206")

    let challenge4 = Day12(data: testDataFour)
    #expect(String(describing: challenge4.part2()) == "236")

    let challenge5 = Day12(data: testDataFive)
    #expect(String(describing: challenge5.part2()) == "368")
  }

}
