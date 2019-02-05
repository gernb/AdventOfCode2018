//
//  main.swift
//  Day 25
//
//  Created by Bohac, Peter on 2/4/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

struct Point: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    let z: Int
    let t: Int

    var description: String {
        return "\(x),\(y),\(z),\(t)"
    }

    func distance(to other: Point) -> Int {
        let xDist = abs(x - other.x)
        let yDist = abs(y - other.y)
        let zDist = abs(z - other.z)
        let tDist = abs(t - other.t)
        return xDist + yDist + zDist + tDist
    }
}

extension Point {
    private init(with string: Substring) {
        let numbers = string.split(separator: ",")
        self.init(x: Int(numbers[0])!, y: Int(numbers[1])!, z: Int(numbers[2])!, t: Int(numbers[3])!)
    }

    static func load(from string: String) -> [Point] {
        return string.split(separator: "\n").map(Point.init)
    }
}

final class Constellation: Equatable {
    var points: Set<Point>

    init(point: Point) {
        self.points = Set([point])
    }

    func add(_ point: Point) {
        points.insert(point)
    }

    static func == (lhs: Constellation, rhs: Constellation) -> Bool {
        return lhs === rhs
    }
}

extension Constellation: CustomStringConvertible {
    var description: String {
        return "<Constellation (\(points.hashValue)): \(points.count) points: \(points)>"
    }
}

let points = Point.load(from: InputData.challenge)
print("Count:", points.count)

func partOneSolution(with points: [Point]) {
    var constellationForPoint: [Point: Constellation] = [:]
    // Every point starts in it's own constellation
    points.forEach { point in constellationForPoint[point] = Constellation(point: point) }

    // brute force
    for (i, point1) in points.enumerated() {
        let constellation1 = constellationForPoint[point1]!
        for j in (i + 1) ..< points.count {
            let point2 = points[j]
            if point1.distance(to: point2) <= 3 {
                let constellation2 = constellationForPoint[point2]!
                constellation2.points.forEach { point in
                    constellation1.add(point)
                    constellationForPoint[point] = constellation1
                }
            }
        }
    }

    let constellations = constellationForPoint.values.reduce([]) { result, element in
        return result.contains(element) ? result : result + [element]
    }
    print("Constellation count:", constellations.count)
}

partOneSolution(with: points)
