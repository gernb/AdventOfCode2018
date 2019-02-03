//
//  main.swift
//  Day 19
//
//  Created by Peter Bohac on 2/2/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

typealias Registers = [Int]

struct Instruction {
    let opcode: Opcode
    let a: Int
    let b: Int
    let c: Int

    func execute(_ registers: inout Registers) {
        opcode.execute(self, registers: &registers)
    }
}

enum Opcode: String {
    case addr, addi
    case mulr, muli
    case banr, bani
    case borr, bori
    case setr, seti
    case gtir, gtri, gtrr
    case eqir, eqri, eqrr

    func execute(_ instruction: Instruction, registers: inout Registers) {
        switch self {
        case .addr:
            registers[instruction.c] = registers[instruction.a] + registers[instruction.b]
        case .addi:
            registers[instruction.c] = registers[instruction.a] + instruction.b

        case .mulr:
            registers[instruction.c] = registers[instruction.a] * registers[instruction.b]
        case .muli:
            registers[instruction.c] = registers[instruction.a] * instruction.b

        case .banr:
            registers[instruction.c] = registers[instruction.a] & registers[instruction.b]
        case .bani:
            registers[instruction.c] = registers[instruction.a] & instruction.b

        case .borr:
            registers[instruction.c] = registers[instruction.a] | registers[instruction.b]
        case .bori:
            registers[instruction.c] = registers[instruction.a] | instruction.b

        case .setr:
            registers[instruction.c] = registers[instruction.a]
        case .seti:
            registers[instruction.c] = instruction.a

        case .gtir:
            registers[instruction.c] = instruction.a > registers[instruction.b] ? 1 : 0
        case .gtri:
            registers[instruction.c] = registers[instruction.a] > instruction.b ? 1 : 0
        case .gtrr:
            registers[instruction.c] = registers[instruction.a] > registers[instruction.b] ? 1 : 0

        case .eqir:
            registers[instruction.c] = instruction.a == registers[instruction.b] ? 1 : 0
        case .eqri:
            registers[instruction.c] = registers[instruction.a] == instruction.b ? 1 : 0
        case .eqrr:
            registers[instruction.c] = registers[instruction.a] == registers[instruction.b] ? 1 : 0
        }
    }
}

final class Program {
    let instructions: [Instruction]
    let ipRegister: Int
    var ip: Int
    var registers: Registers

    init(instructions: [Instruction], ipRegister: Int) {
        self.instructions = instructions
        self.ipRegister = ipRegister
        self.ip = 0
        self.registers = Array(repeating: 0, count: 6)
    }

    func run(initialRegisters: Registers = [0,0,0,0,0,0]) {
        ip = 0
        registers = initialRegisters
        while ip < instructions.count {
            registers[ipRegister] = ip
            instructions[ip].execute(&registers)
            ip = registers[ipRegister]
            ip += 1
        }
    }
}

extension Instruction {
    init(with string: Substring) {
        let parts = string.split(separator: " ")
        let opcode = Opcode(rawValue: String(parts[0]))!
        self.init(opcode: opcode, a: Int(parts[1])!, b: Int(parts[2])!, c: Int(parts[3])!)
    }
}

extension Program {
    static func load(from string: String) -> Program {
        let lines = string.split(separator: "\n")
        let ipRegister = Int(lines[0].split(separator: " ")[1])!
        let instructions = lines.dropFirst().map(Instruction.init)
        return Program(instructions: instructions, ipRegister: ipRegister)
    }
}

let program = Program.load(from: InputData.challenge)
program.run()
print(program.registers[0])

//program.run(initialRegisters: [1,0,0,0,0,0])
//print(program.registers[0])

// decompiling the program yields the purpose is to sum all the factors of 10_551_300 (or 900 for part 1).
let value = 10_551_300
var sum = 0
for x in (1...value) {
    for y in (1...value) {
        let result = x * y
        if result == value {
            sum += x
        }
        if result > value {
            break
        }
    }
}
print("Part 2 solution:", sum)
