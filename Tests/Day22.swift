import Testing

@testable import AdventOfCode

struct Day22Tests {
  let testData = """
    1
    10
    100
    2024
    """

  let testData2 = """
    1
    2
    3
    2024
    """

  @Test func testPart1() async throws {
    let challenge = Day22(data: testData)
    #expect(String(describing: challenge.part1()) == "37327623")
  }

  @Test func testPart2() async throws {
    let challenge = Day22(data: testData2)
    #expect(String(describing: challenge.part2()) == "23")
  }



}
