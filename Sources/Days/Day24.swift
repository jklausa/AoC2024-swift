import Algorithms

struct Day24: AdventDay {
  var data: String

  enum Operation: String {
    case AND
    case OR
    case XOR
  }

  struct Instruction {
    var firstOperand: String
    var secondOperand: String
    var operation: Operation

    var destination: String
  }

  var entities: ([String: Bool], [Instruction]) {
    let sections =
      data
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .split(separator: "\n\n")

    let initialValues: [String: Bool] = sections[0]
      .split(separator: "\n")
      .reduce(into: [:]) {
        let line = $1
        let parts = line.split(separator: ": ")

        $0[String(parts[0])] = parts[1] == "1"
      }

    let instructions = sections[1]
      .split(separator: "\n")
      .map { line in
        let parts = line.split(separator: " ")
        let firstOperand = String(parts[0])
        let operation = Operation(rawValue: String(parts[1]))!
        let secondOperand = String(parts[2])
        let destination = String(parts[4])
        return Instruction(
          firstOperand: firstOperand,
          secondOperand: secondOperand,
          operation: operation,
          destination: destination)
      }

    return (initialValues, instructions)
  }

  func part1() -> Any {
    let (initialValues, instructions) = entities

    var values = initialValues

    var instructionStack: Deque<Instruction> = .init(instructions)

    while let instruction = instructionStack.popFirst() {
      guard let firstValue = values[instruction.firstOperand],
        let secondValue = values[instruction.secondOperand]
      else {
        instructionStack.append(instruction)
        continue
      }

      let result: Bool
      switch instruction.operation {
      case .AND:
        result = firstValue && secondValue
      case .OR:
        result = firstValue || secondValue
      case .XOR:
        result = firstValue != secondValue
      }

      values[instruction.destination] = result
    }

    let digitKeys = values
      .keys
      .filter { $0.first == "z" }
      .sorted()
      .reversed()

    let binaryNumber =
      digitKeys
      .map { values[$0]! ? "1" : "0" }
      .joined()

    return Int(binaryNumber, radix: 2) ?? 0
  }

  func part2() -> Any {
    return 0
    // entities.map { $0.max() ?? 0 }.reduce(0, +)
  }
}
