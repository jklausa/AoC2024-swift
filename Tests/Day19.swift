import Testing

@testable import AdventOfCode

struct Day19Tests {
  let testData = """
    r, wr, b, g, bwu, rb, gb, br
    
    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
    """

  let testDataTwo = """
g, rrg, rr, gu

grrgu
"""

  @Test func testPart1() async throws {
    let challenge = Day19(data: testData)
    #expect(String(describing: challenge.part1()) == "6")
  }

  @Test func testPart1Two() async throws {
    let challenge = Day19(data: testDataTwo)
    #expect(String(describing: challenge.part1()) == "1")
  }

  @Test func testPart2() async throws {
    let challenge = Day19(data: testData)
    #expect(String(describing: challenge.part1()) == "16")
  }
}
