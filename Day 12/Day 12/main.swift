//
//  main.swift
//  Day 12
//
//  Created by Peter Bohac on 1/30/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Pot {
    let id: Int
    var containsPlant: Bool

    init(_ id: Int, _ containsPlant: Bool) {
        self.id = id
        self.containsPlant = containsPlant
    }
}

extension Pot: CustomStringConvertible {
    var description: String {
        return containsPlant ? "#" : "."
    }
}

struct Rule {
    let pattern: [Bool]
    let growsPlant: Bool

    func matches(_ slice: ArraySlice<Pot>) -> Bool {
        let input = Array(slice.map { $0.containsPlant })
        return input == pattern
    }

    static var `default`: Rule {
        return Rule(pattern: [], growsPlant: false)
    }
}

extension Rule {
    init(from string: Substring) {
        let parts = string.split(separator: " ")
        self.pattern = parts[0].map { $0 == "#" }
        self.growsPlant = parts[2] == "#"
    }
}

final class State {
    var pots: [Pot]
    let rules: [Rule]
    var generation: Int

    private init(pots: [Pot], rules: [Rule]) {
        self.pots = pots
        self.rules = rules
        self.generation = 0
    }

    static func load(data: String) -> State {
        var lines = data.split(separator: "\n")
        let initialState = lines[0].split(separator: " ")[2]
        var id = 0
        let pots = initialState.map { char -> Pot in
            let pot = Pot(id, char == "#")
            id += 1
            return pot
        }
        let rules = lines.dropFirst().map(Rule.init)
        return State(pots: pots, rules: rules)
    }

    func advance() {
        let firstId = pots.first!.id
        let lastId = pots.last!.id
        let extendedPots = [Pot(firstId - 3, false), Pot(firstId - 2, false), Pot(firstId - 1, false)]
            + pots +
            [Pot(lastId + 1, false), Pot(lastId + 2, false), Pot(lastId + 3, false)]
        var newPots: [Pot] = []
        newPots.reserveCapacity(extendedPots.count)
        for i in 2 ..< (extendedPots.count - 2) {
            let pot = extendedPots[i]
            let slice = extendedPots[i - 2 ... i + 2]
            let rule = rules.first { $0.matches(slice) } ?? Rule.default
            newPots.append(Pot(pot.id, rule.growsPlant))
        }
        pots = trim(newPots)
        generation += 1
    }

    private func trim(_ pots: [Pot]) -> [Pot] {
        let slice = pots.drop { $0.containsPlant == false}
            .reversed()
            .drop { $0.containsPlant == false}
            .reversed()
        return Array(slice)
    }
}

extension State: CustomStringConvertible {
    var description: String {
        return String(format: "%2d: %@ value: %d", generation, pots.map { $0.description }.joined(), potsValue)
    }
}

extension State {
    var potsValue: Int {
        return pots.filter { $0.containsPlant }.reduce(0) { $0 + $1.id }
    }
}

let state = State.load(data: challengeInput)
func partOneSolution() {
    print(state)
    (1 ... 20).forEach { _ in
        state.advance()
        print(state)
    }
}

func partTwoSolution() {
    print("Finding steady state...")
    var prevValue = 0
    var prevDelta = 0
    repeat {
        state.advance()
        let value = state.potsValue
        let delta = value - prevValue
        print(state.generation, delta)
        if delta == prevDelta {
            break
        }
        prevValue = value
        prevDelta = delta
    } while true

    print(prevValue, prevDelta, state.potsValue)

    let finalValue = state.potsValue + prevDelta * (50_000_000_000 - state.generation)
    print("Solution:", finalValue)
}

//partOneSolution()
partTwoSolution()

print("Done!")
