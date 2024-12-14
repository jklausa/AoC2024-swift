import Accelerate
import Algorithms
import Collections

struct Day13: AdventDay {
  var data: String

  struct Machine {
    var aButton: (Int, Int)
    var bButton: (Int, Int)

    var prizeLocation: (Int, Int)

    func canBeSolved(with aButtonCount: Int, bButtonPressCount: Int) -> Bool {
      let newX = aButton.0 * aButtonCount + bButton.0 * bButtonPressCount
      let newY = aButton.1 * aButtonCount + bButton.1 * bButtonPressCount

      return newX == prizeLocation.0 && newY == prizeLocation.1
    }
  }

  var machines: [Machine] {
    let sections = data.split(separator: "\n\n")

    let foo =
      try? sections
      .map {
        let lines = $0.split(separator: "\n")

        let buttonRegex = /X\+(\d+)\, Y\+(\d+)/

        let aButton = try buttonRegex.firstMatch(in: String(lines[0]))!
        let bButton = try buttonRegex.firstMatch(in: String(lines[1]))!

        let prizeRegex = /X\=(\d+), Y\=(\d+)/

        let prizeLocation = try prizeRegex.firstMatch(in: lines[2])!

        return Machine(
          aButton: (Int(aButton.output.1)!, Int(aButton.output.2)!),
          bButton: (Int(bButton.output.1)!, Int(bButton.output.2)!),
          prizeLocation: (Int(prizeLocation.output.1)!, Int(prizeLocation.output.2)!)
        )
      }

    return foo!
  }

  struct Position: Hashable {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
      self.x = x
      self.y = y
    }

    init(_ tuple: (Int, Int)) {
      self.x = tuple.0
      self.y = tuple.1
    }
  }

  func findCheapestSolve(for machine: Machine) -> Int {
    let aButtonPressCost = 3
    let bButtonPressCost = 1

    // machine: cost
    var dict: [Position: Int] = [:]

    var machinesToTry: Deque<Position> = [Position(x: 0, y: 0)]
    while let currentMachine = machinesToTry.popFirst() {
      guard dict[currentMachine] == nil else {
        continue
      }

      // this can be solved by pressing b once, save it in the dict
      if Position(machine.bButton) == currentMachine {
        dict[currentMachine] = 1
        continue
      }

      // this can be saved by pressing a once, save it
      if Position(machine.aButton) == currentMachine {
        dict[currentMachine] = 3
        continue
      }

      // does there exist a machine that we solved before, that is
      // one button press away from this machine?
      let currentWithoutB = Position(
        x: currentMachine.x - machine.bButton.0,
        y: currentMachine.y - machine.bButton.1)

      let currentWithoutA = Position(
        x: currentMachine.x - machine.aButton.0,
        y: currentMachine.y - machine.aButton.1)

      if dict[currentWithoutA] != nil, dict[currentWithoutB] != nil {
        dict[currentMachine] = min(
          dict[currentWithoutA]! + aButtonPressCost, dict[currentWithoutB]! + bButtonPressCost)
      } else if dict[currentWithoutA] != nil {
        dict[currentMachine] = dict[currentWithoutA]! + aButtonPressCost
      } else if dict[currentWithoutB] != nil {
        dict[currentMachine] = dict[currentWithoutB]! + bButtonPressCost
      }

      let nextPotentialMachines = [
        Position(
          x: currentMachine.x + machine.aButton.0,
          y: currentMachine.y + machine.aButton.1),
        Position(
          x: currentMachine.x + machine.bButton.0,
          y: currentMachine.y + machine.bButton.1),
        Position(
          x: currentMachine.x + machine.aButton.0 + machine.bButton.0,
          y: currentMachine.y + machine.aButton.1 + machine.bButton.1),
      ].filter {
        $0.x <= machine.prizeLocation.0 && $0.y <= machine.prizeLocation.1
      }

      machinesToTry.append(contentsOf: nextPotentialMachines)
    }

    return dict[Position(machine.prizeLocation)] ?? 0
  }

  func part1() -> Any {
    let parsedMachines = machines

    return parsedMachines.map { findCheapestSolve(for: $0) }.reduce(0, +)
  }

  func part2() throws -> Any {
    if #available(macOS 13.3, *) {
      return try part2Implementation()
    } else {
      return 0
    }
  }

  @available(macOS 13.3, *)
  func part2Implementation() throws -> Int {
    let bigMachines = machines.map {
      Machine(
        aButton: $0.aButton,
        bButton: $0.bButton,
        prizeLocation: (
          $0.prizeLocation.0 + 10_000_000_000_000, $0.prizeLocation.1 + 10_000_000_000_000
        )
      )
    }

    let solves = try bigMachines.map { machine in
      var matrixA: [Double] = [
        machine.aButton.0, machine.bButton.0,
        machine.aButton.1, machine.bButton.1,
      ].map { Double($0) }

      var matrixB: [Double] = [
        Double(machine.prizeLocation.0),
        Double(machine.prizeLocation.1),
      ]

      try Solver.solveLinearSystem(matrixA: &matrixA, matrixB: &matrixB, count: 2)

      let x = matrixB[0]
      let y = matrixB[1]

      let xDistance = abs(x.distance(to: x.rounded()))
      let yDistance = abs(y.distance(to: y.rounded()))

      if xDistance > 0.05 || yDistance > 0.05 {
        // This means the results are not integers, and therefore non-solvable.
        return 0
      }

      return Int(x.rounded()) * 3 + Int(y.rounded())
    }

    return solves.reduce(0, +)
  }
}

/// All of this is just copy-paste from this: https://developer.apple.com/documentation/accelerate/solving_systems_of_linear_equations_with_lapack
@available(macOS 13.3, *)
struct Solver {

  static func solveLinearSystem(
    matrixA: inout [Double],
    matrixB: inout [Double],
    count: Int
  ) throws {

    /// By default, LAPACK expects matrices in column-major format. Specify transpose to support
    /// the row-major Vandermonde matrix.
    let trans = Int8("T".utf8.first!)

    /// Pass `-1` to the `lwork` parameter of `dgels_` to calculate the optimal size for the
    /// workspace array. The function writes the optimal size to the `workDimension` variable.
    var workspaceCount = Double(0)
    let err = dgels(
      transpose: trans,
      rowCount: count,
      columnCount: count,
      rightHandSideCount: 1,
      matrixA: &matrixA, leadingDimensionA: count,
      matrixB: &matrixB, leadingDimensionB: count,
      workspace: &workspaceCount,
      workspaceCount: -1)

    if err != 0 {
      throw LAPACKError.internalError
    }

    ///  Create the workspace array based on the workspace query result.
    let workspace = UnsafeMutablePointer<Double>.allocate(
      capacity: Int(workspaceCount))
    defer {
      workspace.deallocate()
    }

    /// Perform the solve by passing the workspace array size to the `lwork` parameter of `dgels_`.
    let info = dgels(
      transpose: trans,
      rowCount: count,
      columnCount: count,
      rightHandSideCount: 1,
      matrixA: &matrixA, leadingDimensionA: count,
      matrixB: &matrixB, leadingDimensionB: count,
      workspace: workspace,
      workspaceCount: Int(workspaceCount))

    if info < 0 {
      throw LAPACKError.parameterHasIllegalValue(parameterIndex: abs(Int(info)))
    } else if info > 0 {
      throw LAPACKError.diagonalElementOfTriangularFactorIsZero(index: Int(info))
    }
  }

  public enum LAPACKError: Swift.Error {
    case internalError
    case parameterHasIllegalValue(parameterIndex: Int)
    case diagonalElementOfTriangularFactorIsZero(index: Int)
  }

  private static func dgels(
    transpose trans: CChar,
    rowCount m: Int,
    columnCount n: Int,
    rightHandSideCount nrhs: Int,
    matrixA a: UnsafeMutablePointer<Double>,
    leadingDimensionA lda: Int,
    matrixB b: UnsafeMutablePointer<Double>,
    leadingDimensionB ldb: Int,
    workspace work: UnsafeMutablePointer<Double>,
    workspaceCount lwork: Int
  ) -> Int32 {

    var info = Int32(0)

    withUnsafePointer(to: trans) { trans in
      withUnsafePointer(to: __LAPACK_int(m)) { m in
        withUnsafePointer(to: __LAPACK_int(n)) { n in
          withUnsafePointer(to: __LAPACK_int(nrhs)) { nrhs in
            withUnsafePointer(to: __LAPACK_int(lda)) { lda in
              withUnsafePointer(to: __LAPACK_int(ldb)) { ldb in
                withUnsafePointer(to: __LAPACK_int(lwork)) { lwork in
                  dgels_(
                    trans, m, n,
                    nrhs,
                    a, lda,
                    b, ldb,
                    work, lwork,
                    &info)
                }
              }
            }
          }
        }
      }
    }

    return info
  }
}
