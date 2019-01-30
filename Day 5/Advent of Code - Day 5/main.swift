//
//  main.swift
//  Advent of Code - Day 5
//
//  Created by Bohac, Peter on 1/29/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

extension String {
    var oppositePolarityUnit: String? {
        guard self.count == 1 else { return nil }
        if self == self.uppercased() {
            return self.lowercased()
        } else {
            return self.uppercased()
        }
    }
}

func react(_ input: [String]) -> (output: [String], reactionsOccurred: Bool) {
    guard input.count > 1 else { return (input, false) }
    var reactionsOccurred = false
    var polymer = [String]()
    polymer.reserveCapacity(input.count)
    var i = 0
    repeat {
        let unit = input[i]
        let nextUnit = input[i + 1]
        if unit.oppositePolarityUnit != nextUnit {
            polymer.append(unit)
            i += 1
        } else {
            reactionsOccurred = true
            i += 2
        }
    } while i < input.count - 1
    if i == (input.count - 1) {
        let lastUnit = input.last!
        polymer.append(lastUnit)
    }

    return (polymer, reactionsOccurred)
}

//print(react("aA".map(String.init)))
//print(react("abBA".map(String.init)))
//print(react("abAB".map(String.init)))

func fullyReact(_ polymer: String) -> (newPolymer: String, iterations: Int) {
    var input = polymer.map(String.init)
    var reactionsOccurred = false
    var count = 0
    repeat {
        count += 1
//        print("Iteration #\(count)")
        (input, reactionsOccurred) = react(input)
    } while reactionsOccurred

    return (input.joined(), count)
}

func partOne(_ data: String) {
    let (result, count) = fullyReact(data)
    print("New polymer length: \(result.count) after \(count) iterations.")
}

//partOne(challengeInput)

func partTwo(_ data: String) {
    let (polymer, _) = fullyReact(data)
    var shortestLength = (count: Int.max, unit: "")
    for unit in Array("abcdefghijklmnopqrstuvwxyz") {
        let oppositeUnit = String(unit).oppositePolarityUnit!.first!
        print("Checking \(unit)\(oppositeUnit)...")
        let newPolymer = polymer.filter { $0 != unit && $0 != oppositeUnit }
        let (result, _) = fullyReact(newPolymer)
        if result.count < shortestLength.count {
            shortestLength = (result.count, String(unit))
        }
    }
    print("Removing '\(shortestLength.unit)' results in the shortest length of \(shortestLength.count)")
}

partTwo(challengeInput)
