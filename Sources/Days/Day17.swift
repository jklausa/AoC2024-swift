import Algorithms

struct Day17: AdventDay {
  var data: String

  protocol Instruction {
    func execute(vm: inout VMState)
  }

  enum LiteralInstruction: Instruction {
    case bxl(Int)
    case jnz(Int)
    case bxc

    func execute(vm: inout Day17.VMState) {
      switch self {
      case .bxl(let operand):
        executeBxl(vm: &vm, operand: operand)
      case .jnz(let operand):
        executeJnz(vm: &vm, operand: operand)
      case .bxc:
        executeBxc(vm: &vm)
      }
    }

    private func executeBxl(vm: inout VMState, operand: Int) {
      let result = vm.rB ^ operand

      vm.rB = result
      vm.ip += 1
    }

    private func executeJnz(vm: inout VMState, operand: Int) {
      guard vm.rA != 0 else {
        vm.ip += 1
        return
      }

      // To allow for that we skip the operands in the list
      vm.ip = operand / 2
    }

    private func executeBxc(vm: inout VMState) {
      let result = vm.rB ^ vm.rC

      vm.rB = result
      vm.ip += 1
    }
  }

  enum ComboInstruction: Instruction {
    case adv(Int)
    case bdv(Int)
    case cdv(Int)

    case bst(Int)
    case out(Int)

    func calculateOperandValue(operand: Int, in vm: VMState) -> Int {
      if operand == 4 {
        return vm.rA
      } else if operand == 5 {
        return vm.rB
      } else if operand == 6 {
        return vm.rC
      } else if operand == 7 {
        fatalError()
      }

      return operand
    }

    func execute(vm: inout Day17.VMState) {
      switch self {

      case .adv(let operand):
        executeDivision(vm: &vm,
                        operand: calculateOperandValue(operand: operand,
                                                       in: vm),
                        destinationRegister: .regA
        )
      case .bdv(let operand):
        executeDivision(vm: &vm,
                        operand: calculateOperandValue(operand: operand,
                                                       in: vm),
                        destinationRegister: .regB
        )

      case .cdv(let operand):
        executeDivision(vm: &vm,
                        operand: calculateOperandValue(operand: operand,
                                                       in: vm),
                        destinationRegister: .regC
        )
      case .bst(let operand):
        executeBst(vm: &vm,
                   operand: calculateOperandValue(operand: operand,
                                                  in: vm)
        )
      case .out(let operand):
        executeOut(vm: &vm,
                   operand: calculateOperandValue(operand: operand,
                                                  in: vm))
      }
    }

    private enum DestinationRegister {
      case regA
      case regB
      case regC
    }

    private func executeDivision(vm: inout VMState,
                                 operand: Int,
                                 destinationRegister: DestinationRegister) {
      let denominator = 1 << operand

      let result = vm.rA / denominator

      switch destinationRegister {
      case .regA:
        vm.rA = result
      case .regB:
        vm.rB = result
      case .regC:
        vm.rC = result
      }

      vm.ip += 1
    }

    private func executeBst(vm: inout VMState, operand: Int) {
      vm.rB = operand % 8

      vm.ip += 1
    }

    private func executeOut(vm: inout VMState, operand: Int) {
      vm.output.append(operand % 8)

      vm.ip += 1
    }
  }

  struct VMState {
    var ip: Int
    var rA: Int
    var rB: Int
    var rC: Int

    let rawProgramInput: [String]
    var instructions: [any Instruction]
    var output: [Int]

    mutating func execute() {
      while ip < instructions.count {
        instructions[ip].execute(vm: &self)
      }
    }
  }

  var parsedInput: VMState {
    let sections = data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n\n")

    let state = sections.first!.components(separatedBy: .newlines)
    // dropFirst "Register A:"
    let regA = Int(String(state[0].dropFirst(12)))!
    let regB = Int(String(state[1].dropFirst(12)))!
    let regC = Int(String(state[1].dropFirst(12)))!

    // drop "Program: "
    let rawProgramInput = sections.last!.dropFirst(9).components(separatedBy: ",")

    var instructionsStrings: Deque<String> = .init(rawProgramInput)
    var instructions: [Instruction] = []

    while let currentInstruction = instructionsStrings.popFirst() {
      let operand = Int(instructionsStrings.popFirst()!)!

      switch Int(currentInstruction)! {
      case 0:
        instructions.append(ComboInstruction.adv(operand))
      case 1:
        instructions.append(LiteralInstruction.bxl(operand))
      case 2:
        instructions.append(ComboInstruction.bst(operand))
      case 3:
        instructions.append(LiteralInstruction.jnz(operand))
      case 4:
        instructions.append(LiteralInstruction.bxc)
      case 5:
        instructions.append(ComboInstruction.out(operand))
      case 6:
        instructions.append(ComboInstruction.bdv(operand))
      case 7:
        instructions.append(ComboInstruction.cdv(operand))
      default:
        fatalError("Unknown instruction")
      }
    }

    return VMState(ip: 0,
                   rA: regA,
                   rB: regB,
                   rC: regC,
                   rawProgramInput: rawProgramInput,
                   instructions: instructions,
                   output: []
    )
  }

  func part1() -> Any {
    var vm = parsedInput

    vm.execute()

    return vm.output.map { String($0) }.joined(separator: ",")
  }

  func part2() -> Any {
    let initialVm = parsedInput

    // answer count == octet count
    // least significant octet influences the next digit
    // check if next digit fits the requireed, add it to the / check if next digit fits the

    let searchedInput = initialVm.rawProgramInput.compactMap { Int($0) }

    var viableInputs: Deque<Int> = [0, 1, 2, 3, 4, 5, 6, 7]
    var actualOutputs: [Int] = []

    while let input = viableInputs.popFirst() {
      var newVM = initialVm
      newVM.rA = input

      newVM.execute()

      let length = newVM.output.count

      if length == searchedInput.count, searchedInput == newVM.output {
        actualOutputs.append(input)
        continue
      }

      if searchedInput.suffix(length) == newVM.output {
        let bitshifted = input << 3

        viableInputs.prepend(bitshifted)
        viableInputs.prepend(bitshifted + 1)
        viableInputs.prepend(bitshifted + 2)
        viableInputs.prepend(bitshifted + 3)
        viableInputs.prepend(bitshifted + 4)
        viableInputs.prepend(bitshifted + 5)
        viableInputs.prepend(bitshifted + 5)
        viableInputs.prepend(bitshifted + 6)
        viableInputs.prepend(bitshifted + 7)
      }

    }

    return actualOutputs.min()!
  }

}
extension Day17.Instruction {
  func execute(vm: inout Day17.VMState) {
    fatalError()
  }
}
