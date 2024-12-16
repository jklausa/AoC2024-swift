import Testing

@testable import AdventOfCode

struct Day16Tests {
  let testData = """
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

  let testData2 = """
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
"""

  @Test func testPart1() async throws {
    let challenge = Day16(data: testData)
    #expect(String(describing: challenge.part1()) == "7036")
  }

  @Test func testPart1SecondExample() async throws {
    let challenge = Day16(data: testData2)
    #expect(String(describing: challenge.part1()) == "11048")
  }

  @Test func testPart2() async throws {
    let challenge = Day16(data: testData)
    #expect(String(describing: challenge.part2()) == "45")
  }

  @Test func testPart2SecondExample() async throws {
    let challenge = Day16(data: testData2)
    #expect(String(describing: challenge.part2()) == "64")
  }
}
