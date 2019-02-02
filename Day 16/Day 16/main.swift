//
//  main.swift
//  Day 16
//
//  Created by Peter Bohac on 2/2/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

typealias Registers = [Int]

struct Command {
    let opcode: Int
    let a: Int
    let b: Int
    let c: Int
}

struct Sample {
    let command: Command
    let registers: (before: Registers, after: Registers)
}

extension Command {
    init(string: Substring) {
        let parts = string.split(separator: " ")
        self.init(opcode: Int(parts[0])!, a: Int(parts[1])!, b: Int(parts[2])!, c: Int(parts[3])!)
    }
}

extension Sample {
    init(before: Substring, command: Substring, after: Substring) {
        let command = Command(string: command)
        let registers = [before, after].map { line -> Registers in
            let values = line.split(separator: "[")[1].dropLast()
            return values.split(separator: ",").map { Int($0.trimmingCharacters(in: .whitespaces))! }
        }
        self.init(command: command, registers: (registers[0], registers[1]))
    }
}

func load(input: String) -> (samples: [Sample], program: [Command]) {
    var samples = [Sample]()
    var program = [Command]()
    let lines = input.split(separator: "\n")
    var index = 0

    while index < lines.count {
        if lines[index].hasPrefix("Before") {
            let sample = Sample(before: lines[index], command: lines[index+1], after: lines[index+2])
            samples.append(sample)
            index += 3
        } else {
            program.append(Command(string: lines[index]))
            index += 1
        }
    }

    return (samples, program)
}

enum Instruction: CaseIterable, Hashable {
    case addr, addi
    case mulr, muli
    case banr, bani
    case borr, bori
    case setr, seti
    case gtir, gtri, gtrr
    case eqir, eqri, eqrr

    func execute(_ command: Command, registers: inout Registers) {
        switch self {
        case .addr:
            registers[command.c] = registers[command.a] + registers[command.b]
        case .addi:
            registers[command.c] = registers[command.a] + command.b

        case .mulr:
            registers[command.c] = registers[command.a] * registers[command.b]
        case .muli:
            registers[command.c] = registers[command.a] * command.b

        case .banr:
            registers[command.c] = registers[command.a] & registers[command.b]
        case .bani:
            registers[command.c] = registers[command.a] & command.b

        case .borr:
            registers[command.c] = registers[command.a] | registers[command.b]
        case .bori:
            registers[command.c] = registers[command.a] | command.b

        case .setr:
            registers[command.c] = registers[command.a]
        case .seti:
            registers[command.c] = command.a

        case .gtir:
            registers[command.c] = command.a > registers[command.b] ? 1 : 0
        case .gtri:
            registers[command.c] = registers[command.a] > command.b ? 1 : 0
        case .gtrr:
            registers[command.c] = registers[command.a] > registers[command.b] ? 1 : 0

        case .eqir:
            registers[command.c] = command.a == registers[command.b] ? 1 : 0
        case .eqri:
            registers[command.c] = registers[command.a] == command.b ? 1 : 0
        case .eqrr:
            registers[command.c] = registers[command.a] == registers[command.b] ? 1 : 0
        }
    }
}

extension Instruction {
    func matches(sample: Sample) -> Bool {
        var registers = sample.registers.before
        execute(sample.command, registers: &registers)
        return registers == sample.registers.after
    }
}

func partOneSolution(with samples: [Sample]) -> [Int] {
    return samples.map { sample in
        let matches = Instruction.allCases.map { instruction -> Int in
            return instruction.matches(sample: sample) ? 1 : 0
        }
        return matches.reduce(0, +)
    }
}

func partTwoSolution(samples: [Sample], program: [Command]) -> Registers {
    var instructionSamples: [Instruction: [Sample]] = {
        var initial: [Instruction: [Sample]] = [:]
        Instruction.allCases.forEach { initial[$0] = [] }
        return initial
    }()
    samples.forEach { sample in
        Instruction.allCases.forEach { instruction in
            if instruction.matches(sample: sample) {
                instructionSamples[instruction]!.append(sample)
            }
        }
    }

    var opcodes: [Instruction?] = Array(repeating: nil, count: Instruction.allCases.count)
    repeat {
        Instruction.allCases.forEach { instruction in
            let samples = instructionSamples[instruction]!
                .filter { opcodes[$0.command.opcode] == nil }
            var didFind: [Int: Bool] = [:]
            let uniqueSamples = samples.filter { sample in
                return didFind.updateValue(true, forKey: sample.command.opcode) == nil
            }
            if uniqueSamples.count == 1 {
                let opcode = uniqueSamples.first!.command.opcode
                opcodes[opcode] = instruction
                instructionSamples[instruction] = []
            } else {
                instructionSamples[instruction] = uniqueSamples
            }
        }
    } while opcodes.contains(nil)

    var registers = [0, 0, 0, 0]
    program.forEach { command in
        let instruction = opcodes[command.opcode]!
        instruction.execute(command, registers: &registers)
    }
    return registers
}

let (samples, program) = load(input: InputData.challenge)
let result = partOneSolution(with: samples)
let count = result.filter { $0 >= 3 }.count
print("Samples matching 3 or more opcodes:", count)

let finalRegisters = partTwoSolution(samples: samples, program: program)
print("Value in register 0:", finalRegisters[0])

print("Done")
