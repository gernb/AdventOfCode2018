//
//  main.swift
//  Day 22
//
//  Created by Peter Bohac on 2/3/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var up: Coordinate { return Coordinate(x: x, y: y - 1) }
    var down: Coordinate { return Coordinate(x: x, y: y + 1) }
    var left: Coordinate { return Coordinate(x: x - 1, y: y) }
    var right: Coordinate { return Coordinate(x: x + 1, y: y) }

    var neighbors: [Coordinate] {
        return [up, left, right, down]
    }

    var description: String {
        return "\(x),\(y)"
    }

    func distance(to other: Coordinate) -> Int {
        return abs(self.x - other.x) + abs(self.y - other.y)
    }
}

final class Cave {
    typealias ErosionLevel = Int

    enum Region: String, CaseIterable {
        case rocky = "."
        case wet = "="
        case narrow = "|"

        var risk: Int {
            switch self {
            case .rocky: return 0
            case .wet: return 1
            case .narrow: return 2
            }
        }

        init(erosionLevel: ErosionLevel) {
            let index = erosionLevel % Region.allCases.count
            self = Region.allCases[index]
        }
    }

    let depth: Int
    var regions: [[ErosionLevel]]
    let mouth: Coordinate
    let target: Coordinate

    init(depth: Int, target: Coordinate) {
        self.depth = depth
        self.mouth = Coordinate(x: 0, y: 0)
        self.target = target

        var regions = Array(repeating: Array(repeating: 0, count: target.x + 1), count: target.y + 1)
        for y in (0 ..< regions.count) {
            for x in (0 ..< regions[y].count) {
                let coord = Coordinate(x: x, y: y)
                let geoIndex = coord == target ? 0 : Cave.geologicIndex(at: coord, with: regions)
                let erosionLevel = (geoIndex + depth) % 20183
                regions[y][x] = erosionLevel
            }
        }
        self.regions = regions
    }

    func riskLevel(upperLeft: Coordinate, lowerRight: Coordinate) -> Int {
        let x = upperLeft.x
        let xSpan = lowerRight.x - upperLeft.x + 1
        let y = upperLeft.y
        let ySpan = lowerRight.y - upperLeft.y + 1
        return regions.dropFirst(y).prefix(ySpan).map { row in
            return row.dropFirst(x).prefix(xSpan).map { level in
                return Region(erosionLevel: level).risk
            }.reduce(0, +)
        }.reduce(0, +)
    }

    // MARK: Private functions

    private static func geologicIndex(at coord: Coordinate, with regions: [[ErosionLevel]]) -> Int {
        if coord.y == 0 {
            return coord.x * 16807
        } else if coord.x == 0 {
            return coord.y * 48271
        } else {
            let left = regions[coord.y][coord.x - 1]
            let up = regions[coord.y - 1][coord.x]
            return left * up
        }
    }
}

extension Cave {
    func draw() {
        for (y, line) in regions.enumerated() {
            for (x, level) in line.enumerated() {
                let coord = Coordinate(x: x, y: y)
                if coord == mouth {
                    print("M", terminator: "")
                } else if coord == target {
                    print("T", terminator: "")
                } else {
                    let region = Region(erosionLevel: level)
                    print(region.rawValue, terminator: "")
                }
            }
            print("")
        }
    }
}

let sampleCave = Cave(depth: 510, target: Coordinate(x: 10, y: 10))
sampleCave.draw()
print(sampleCave.riskLevel(upperLeft: sampleCave.mouth, lowerRight: sampleCave.target))

let challengeCave = Cave(depth: 7740, target: Coordinate(x: 12, y: 763))
//challengeCave.draw()
//print(challengeCave.riskLevel(upperLeft: challengeCave.mouth, lowerRight: challengeCave.target))

extension Cave {
    subscript(x: Int, y: Int) -> Region? {
        get {
            guard x >= 0 && y >= 0 && y < regions.count && x < regions[y].count else { return nil }
            return Region(erosionLevel: regions[y][x])
        }
    }

    subscript(coord: Coordinate) -> Region? {
        get { return self[coord.x, coord.y] }
    }

    func addRow() {
        let y = regions.count
        let row = Array(repeating: 0, count: regions[0].count)
        regions.append(row)
        for x in 0 ..< row.count {
            let coord = Coordinate(x: x, y: y)
            let geoIndex = Cave.geologicIndex(at: coord, with: regions)
            let erosionLevel = (geoIndex + depth) % 20183
            regions[y][x] = erosionLevel
        }
    }

    func addColumn() {
        let x = regions[0].count
        for y in 0 ..< regions.count {
            let coord = Coordinate(x: x, y: y)
            let geoIndex = Cave.geologicIndex(at: coord, with: regions)
            let erosionLevel = (geoIndex + depth) % 20183
            regions[y].append(erosionLevel)
        }
    }

    func getNeighboringRegions(of coord: Coordinate) -> [(Coordinate, Region)] {
        var result: [(Coordinate, Region)] = []

        if let up = self[coord.up] {
            result.append((coord.up, up))
        }
        if let left = self[coord.left] {
            result.append((coord.left, left))
        }
        if let down = self[coord.down] {
            result.append((coord.down, down))
        } else {
            addRow()
            result.append((coord.down, self[coord.down]!))
        }
        if let right = self[coord.right] {
            result.append((coord.right, right))
        } else {
            addColumn()
            result.append((coord.right, self[coord.right]!))
        }

        return result
    }
}

final class Player {
    enum Equipment: Equatable {
        case none, torch, climbingGear
    }

    struct State: Hashable {
        let equipment: Equipment
        let position: Coordinate
    }

    var cave: Cave

    init(cave: Cave) {
        self.cave = cave
    }

    func shortestTime() -> Int {
        let initialState = State(equipment: .torch, position: cave.mouth)
        let targetState = State(equipment: .torch, position: cave.target)
        var seen: [State: Int] = [:]
        var queue: [State: (time: Int, estimatedTime: Int)] = [initialState: (0, 0)]

        while let (state, (time, _)) = queue.min(by: { $0.value.estimatedTime < $1.value.estimatedTime }) {
            queue.removeValue(forKey: state)
            if (state == targetState) {
                return time
            }

            let moves = nextStates(from: state)
            moves.forEach { newState, cost in
                let newTime = time + cost
                if let previouslySeen = seen[newState], previouslySeen < newTime {
                    return
                }
                if let queued = queue[newState], queued.time < newTime {
                    return
                }
                queue[newState] = (newTime, newTime + newState.position.distance(to: targetState.position))
            }

            seen[state] = time
        }

        preconditionFailure("Unreachable!")
    }

    private func nextStates(from state: State) -> [(state: State, time: Int)] {
        var result: [(State, Int)] = []

        let currentRegion = cave[state.position]!
        switch (state.equipment, currentRegion) {
        case (.torch, .rocky):
            result.append((State(equipment: .climbingGear, position: state.position), 7))
        case (.climbingGear, .rocky):
            result.append((State(equipment: .torch, position: state.position), 7))
        case (.none, .rocky):
            preconditionFailure("Impossible combination")
        case (.torch, .wet):
            preconditionFailure("Impossible combination")
        case (.climbingGear, .wet):
            result.append((State(equipment: .none, position: state.position), 7))
        case (.none, .wet):
            result.append((State(equipment: .climbingGear, position: state.position), 7))
        case (.torch, .narrow):
            result.append((State(equipment: .none, position: state.position), 7))
        case (.climbingGear, .narrow):
            preconditionFailure("Impossible combination")
        case (.none, .narrow):
            result.append((State(equipment: .torch, position: state.position), 7))
        }

        let neighbors = cave.getNeighboringRegions(of: state.position)
        neighbors.forEach { coord, region in
            switch (state.equipment, region) {
            case (.torch, .rocky), (.climbingGear, .rocky):
                result.append((State(equipment: state.equipment, position: coord), 1))
            case (.none, .rocky):
                break // move not allowed
            case (.climbingGear, .wet), (.none, .wet):
                result.append((State(equipment: state.equipment, position: coord), 1))
            case (.torch, .wet):
                break // move not allowed
            case (.torch, .narrow), (.none, .narrow):
                result.append((State(equipment: state.equipment, position: coord), 1))
            case (.climbingGear, .narrow):
                break // move not allowed
            }
        }

        return result
    }
}

let player = Player(cave: challengeCave)
print("")
print(player.shortestTime())

print("Done")
