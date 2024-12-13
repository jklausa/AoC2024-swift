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

    let foo = try? sections
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

    var machinesToTry: Deque<Position> = [Position(x:0, y: 0)]
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
      let currentWithoutB = Position(x: currentMachine.x - machine.bButton.0,
                                     y: currentMachine.y - machine.bButton.1)

      let currentWithoutA = Position(x: currentMachine.x - machine.aButton.0,
                                     y: currentMachine.y - machine.aButton.1)

      if dict[currentWithoutA] != nil, dict[currentWithoutB] != nil {
        dict[currentMachine] = min(dict[currentWithoutA]! + aButtonPressCost, dict[currentWithoutB]! + bButtonPressCost)
      } else if dict[currentWithoutA] != nil {
        dict[currentMachine] = dict[currentWithoutA]! + aButtonPressCost
      } else if dict[currentWithoutB] != nil {
        dict[currentMachine] = dict[currentWithoutB]! + bButtonPressCost
      }

      let nextPotentialMachines = [
        Position(x: currentMachine.x + machine.aButton.0,
                 y: currentMachine.y + machine.aButton.1),
        Position(x: currentMachine.x + machine.bButton.0,
                 y: currentMachine.y + machine.bButton.1),
        Position(x: currentMachine.x + machine.aButton.0 + machine.bButton.0,
                 y: currentMachine.y + machine.aButton.1 + machine.bButton.1)
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

  func part2() -> Any {
    return 0
  }
}
