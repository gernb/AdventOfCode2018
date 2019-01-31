//
//  main.swift
//  Day 11
//
//  Created by Peter Bohac on 1/30/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Grid {
    let serialNumber: Int
    let levels: [[Int]]

    init(serialNumber: Int) {
        self.serialNumber = serialNumber
        var levels = Array(repeating: Array(repeating: 0, count: 300), count: 300)
        for (y, line) in levels.enumerated() {
            for (x, _) in line.enumerated() {
                levels[y][x] = Grid.powerLevel(at: x + 1, y + 1, serialNumber: serialNumber)
            }
        }
        self.levels = levels
    }

    private static func powerLevel(at x: Int, _ y: Int, serialNumber: Int) -> Int {
        let rackId = x + 10
        var powerLevel = rackId * y
        powerLevel += serialNumber
        powerLevel *= rackId
        powerLevel = (powerLevel / 100) % 10
        powerLevel -= 5
        return powerLevel
    }

    static func testPowerLevel(_ x: Int, _ y: Int, serial: Int, expected: Int) {
        let level = Grid.powerLevel(at: x, y, serialNumber: serial)
        assert(level == expected, "Failed test!")
    }
}

Grid.testPowerLevel(3, 5, serial: 8, expected: 4)
Grid.testPowerLevel(122, 79, serial: 57, expected: -5)
Grid.testPowerLevel(217, 196, serial: 39, expected: 0)
Grid.testPowerLevel(101, 153, serial: 71, expected: 4)

extension Grid {
    func draw5x5(at x: Int, _ y: Int) {
        for j in y ..< (y + 5) {
            for i in x ..< (x + 5) {
                let value = levels[j - 1][i - 1]
                let text = String.init(format: "%2d  ", value)
                print(text, terminator: "")
            }
            print("\n")
        }
    }
}

// Part 1 (naive) solution
extension Grid {
    func findMaxPowerSquare() -> (x: Int, y: Int, power: Int) {
        var result = (x: -1, y: -1, power: Int.min)
        for y in 0 ..< levels.count - 2 {
            for x in 0 ..< levels[y].count - 2 {
                let power = squarePower(at: x, y, size: 3)
                if power > result.power {
                    result = (x: x+1, y: y+1, power: power)
                }
            }
        }
        return result
    }

    func squarePower(at x: Int, _ y: Int, size: Int) -> Int {
        var power = 0
        for j in y ..< (y + size) {
            for i  in x ..< (x + size) {
                power += levels[j][i]
            }
        }
        return power
    }
}

// Part 2 (naive) solution
extension Grid {
    func findBestSize() -> (x: Int, y: Int, size: Int, power: Int) {
        var result = (x: -1, y: -1, size: 0, power: Int.min)
        for size in 1 ... levels.count {
            print("Size:", size, result)
            for y in 0 ..< (levels.count - (size - 1)) {
                for x in 0 ..< (levels[y].count - (size - 1)) {
                    let power = squarePower(at: x, y, size: size)
                    if power > result.power {
                        result = (x: x+1, y: y+1, size: size, power: power)
                    }
                }
            }
        }
        return result
    }
}

//let grid = Grid(serialNumber: 18)
////grid.draw5x5(at: 32, 44)
////print(grid.squarePower(at: 32, 44, size: 3))
////print(grid.findMaxPowerSquare())
//print(grid.findBestSize())

//let grid = Grid(serialNumber: 42)
////grid.draw5x5(at: 20, 60)
////print(grid.squarePower(at: 20, 60, size: 3))
//print(grid.findMaxPowerSquare())

let grid = Grid(serialNumber: 4172)
print(grid.findMaxPowerSquare())
print(grid.findBestSize())

print("Done!")
