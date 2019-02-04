//
//  main.swift
//  Day 23
//
//  Created by Peter Bohac on 2/3/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    let z: Int

    var description: String {
        return "\(x),\(y),\(z)"
    }

    func distance(to other: Coordinate) -> Int {
        return abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
    }
}

struct Nanobot: Hashable {
    let position: Coordinate
    let radius: Int
}

// MARK: Parsing

extension Coordinate {
    init(from string: Substring) {
        let parts = string.split(separator: "<")
        let numbers = parts[1].dropLast(2).split(separator: ",")
        self.init(x: Int(numbers[0])!, y: Int(numbers[1])!, z: Int(numbers[2])!)
    }
}

extension Nanobot {
    init(from string: Substring) {
        let parts = string.split(separator: " ")
        let position = Coordinate(from: parts[0])
        let radius = Int(parts[1].split(separator: "=")[1])!
        self.init(position: position, radius: radius)
    }

    static func load(from string: String) -> [Nanobot] {
        return string.split(separator: "\n").map(Nanobot.init)
    }
}

// MARK: Solution

extension Collection where Iterator.Element == Nanobot {
    var strongest: Nanobot? {
        return self.max { $0.radius < $1.radius }
    }

    var range: (x: ClosedRange<Int>, y: ClosedRange<Int>, z: ClosedRange<Int>) {
        let coords = self.map { $0.position }
        let xMin = coords.min { $0.x < $1.x }?.x ?? 0
        let xMax = coords.max { $0.x < $1.x }?.x ?? 0
        let yMin = coords.min { $0.y < $1.y }?.y ?? 0
        let yMax = coords.max { $0.y < $1.y }?.y ?? 0
        let zMin = coords.min { $0.z < $1.z }?.z ?? 0
        let zMax = coords.max { $0.z < $1.z }?.z ?? 0
        return (xMin ... xMax, yMin ... yMax, zMin ... zMax)
    }
}

let bots = Nanobot.load(from: InputData.challenge)
print("Count:", bots.count)

let strongest = bots.strongest!
print("Strongest:", strongest)

//let inRange = bots.filter { $0.position.distance(to: strongest.position) <= strongest.radius }
//print("Count in range of strongest:", inRange.count)

extension Nanobot {
    func scaled(by scale: Int) -> Nanobot {
        let scaledPos = Coordinate(x: position.x / scale, y: position.y / scale, z: position.z / scale)
        return Nanobot(position: scaledPos, radius: radius / scale)
    }

    func inRangeOf(_ coord: Coordinate) -> Bool {
        return position.distance(to: coord) <= radius
    }
}

func findOptimalPosition(in bots: [Nanobot]) -> Coordinate {
    var scale = Int(pow(2.0, 28))
    var scaledBots: [Nanobot] = []
    var range = scaledBots.range
    var result: Coordinate!

    repeat {
        print("Scale:", scale)
        scaledBots = bots.map { $0.scaled(by: scale) }
        result = nil
        var bestCount = Int.min

        for z in range.z {
            for y in range.y {
                for x in range.x {
                    let coord = Coordinate(x: x, y: y, z: z)
                    let botsInRange = scaledBots.filter { $0.inRangeOf(coord) }.count
                    if botsInRange > bestCount {
                        result = coord
                        bestCount = botsInRange
                    } else if botsInRange == bestCount {
                        let resultDistance = result.distance(to: Coordinate(x: 0, y: 0, z: 0))
                        let coordDistance = coord.distance(to: Coordinate(x: 0, y: 0, z: 0))
                        if coordDistance < resultDistance {
                            result = coord
                            bestCount = botsInRange
                        }
                    }
                }
            }
        }

        range.x = ((result.x - 1) * 2) ... ((result.x + 1) * 2)
        range.y = ((result.y - 1) * 2) ... ((result.y + 1) * 2)
        range.z = ((result.z - 1) * 2) ... ((result.z + 1) * 2)
        scale = scale / 2
    } while scale >= 1

    return result
}

print(bots.range)
let position = findOptimalPosition(in: bots)
let distance = position.distance(to: Coordinate(x: 0, y: 0, z: 0))
print("\(position) appears to be the best location at \(distance) units away")
