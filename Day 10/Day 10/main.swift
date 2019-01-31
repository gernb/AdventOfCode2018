//
//  main.swift
//  Day 10
//
//  Created by Bohac, Peter on 1/30/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Pair {
    let x: Int
    let y: Int

    static func + (lhs: Pair, rhs: Pair) -> Pair {
        return Pair(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (lhs: inout Pair, rhs: Pair) {
        lhs = lhs + rhs
    }
}

extension Pair {
    init(string: Substring) {
        let parts = string.split(separator: ",").map { Int(String($0).trimmingCharacters(in: .whitespacesAndNewlines))! }
        self.init(x: parts[0], y: parts[1])
    }
}

extension Pair: CustomStringConvertible {
    var description: String {
        return "\(x), \(y)"
    }
}

final class Point {
    var position: Pair
    let velocity: Pair

    init(position: Pair, velocity: Pair) {
        self.position = position
        self.velocity = velocity
    }

    func move() {
        position += velocity
    }
}

extension Point: CustomStringConvertible {
    var description: String {
        return "Pos=<\(position)> Velocity=<\(velocity)>"
    }
}

extension Point {
    static func parse(_ data: String) -> [Point] {
        return data.split(separator: "\n")
            .map { line in
                var sliceStart = line.firstIndex(of: "<")!
                sliceStart = line.index(after: sliceStart)
                var sliceEnd = line.firstIndex(of: ">")!
                let position = Pair(string: line[sliceStart ..< sliceEnd])
                sliceStart = line.lastIndex(of: "<")!
                sliceStart = line.index(after: sliceStart)
                sliceEnd = line.lastIndex(of: ">")!
                let velocity = Pair(string: line[sliceStart ..< sliceEnd])
                return Point(position: position, velocity: velocity)
            }
    }
}

extension Collection where Iterator.Element == Point {

    var extents: (upperLeft: Pair, lowerRight: Pair) {
        var leftX = Int.max
        var rightX = Int.min
        var topY = Int.max
        var bottomY = Int.min
        self.forEach { point in
            leftX = Swift.min(leftX, point.position.x)
            rightX = Swift.max(rightX, point.position.x)
            topY = Swift.min(topY, point.position.y)
            bottomY = Swift.max(bottomY, point.position.y)
        }
        return (Pair(x: leftX, y: topY), Pair(x: rightX, y: bottomY))
    }

    func draw() {
        let extents = self.extents
        let translationVector = Pair(x: abs(Swift.min(0, extents.upperLeft.x)), y: abs(Swift.min(0, extents.upperLeft.y)))
        let max = extents.lowerRight + translationVector
        var display: [[String]] = Array(repeating: Array(repeating: ".", count: max.x + 1), count: max.y + 1)
        self.forEach { point in
            let pos = point.position + translationVector
            display[pos.y][pos.x] = "#"
        }
//        print(display.map { $0.joined() }.joined(separator: "\n"))
        for y in 0 ..< display.count {
            for x in 0 ..< display[y].count {
                print(display[y][x], terminator: "")
            }
            print("")
        }
    }

    func update() {
        self.forEach { point in point.move() }
    }
}

func partOneSolution() {
    let points = Point.parse(challengeInput)
    print("Parsed. Skipping ahead in time...")
    var seconds = 0
    repeat {
        let extents = points.extents
        let height = extents.lowerRight.y - extents.upperLeft.y
        if height <= 20 {
            break
        }
        points.update()
        seconds += 1
        print(".", terminator: "")
    } while true
    print("")

    var input = ""
    repeat {
        points.draw()
        points.update()
        seconds += 1
        print("Continue? ", terminator: "")
        input = readLine() ?? ""
    } while input.lowercased().starts(with: "n") == false

    print("Total seconds:", seconds - 1)
}

partOneSolution()

print("Done!")
