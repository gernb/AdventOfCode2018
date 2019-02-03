//
//  InputData.swift
//  Day 19
//
//  Created by Peter Bohac on 2/2/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

struct InputData {
    static let sample = """
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
"""

    static let challenge = """
#ip 3
addi 3 16 3
seti 1 9 5
seti 1 1 4
mulr 5 4 2
eqrr 2 1 2
addr 2 3 3
addi 3 1 3
addr 5 0 0
addi 4 1 4
gtrr 4 1 2
addr 3 2 3
seti 2 3 3
addi 5 1 5
gtrr 5 1 2
addr 2 3 3
seti 1 4 3
mulr 3 3 3
addi 1 2 1
mulr 1 1 1
mulr 3 1 1
muli 1 11 1
addi 2 2 2
mulr 2 3 2
addi 2 20 2
addr 1 2 1
addr 3 0 3
seti 0 4 3
setr 3 9 2
mulr 2 3 2
addr 3 2 2
mulr 3 2 2
muli 2 14 2
mulr 2 3 2
addr 1 2 1
seti 0 6 0
seti 0 0 3
"""
}
