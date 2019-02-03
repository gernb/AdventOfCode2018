//
//  main.swift
//  Day 21
//
//  Created by Peter Bohac on 2/3/19.
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
    var ip: Int = 0
    var registers: Registers = []
    var executedCount: Int = 0

    init(instructions: [Instruction], ipRegister: Int) {
        self.instructions = instructions
        self.ipRegister = ipRegister
    }

    func run(initialRegisters: Registers = [0,0,0,0,0,0]) {
        ip = 0
        registers = initialRegisters
        executedCount = 0
        while ip < instructions.count {
            registers[ipRegister] = ip
            instructions[ip].execute(&registers)
            ip = registers[ipRegister]
            ip += 1
            executedCount += 1
//            print(ip, executedCount, registers)
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

func swiftyProgram() -> Int {
    let A = 0 //16457176
    var B = 0
    var C = 0
    var D = 0
    var E = 0

    var valuesOfA: [Int] = []

    label: repeat {
        D = E | 65536
        E = 3935295

        repeat {
            B = D & 255
            E = E + B
            E = E & 16777215
            E = E * 65899
            E = E & 16777215
            if 256 > D {
                if valuesOfA.contains(E) {
                    return valuesOfA.last!
                }
                valuesOfA.append(E)
                if E == A {
                    return E
                } else {
                    continue label
                }
            }
            B = 0
            repeat {
                C = B + 1
                C = C * 256
                if C > D { break }
                B = B + 1
            } while true
            D = B
        } while true
    } while true
}

//let program = Program.load(from: challenge)
//program.run(initialRegisters: [0,0,0,0,0,0])

print(swiftyProgram())
