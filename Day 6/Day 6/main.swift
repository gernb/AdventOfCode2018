//
//  main.swift
//  Day 6
//
//  Created by Bohac, Peter on 1/29/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Coordinate: Equatable, Hashable {
    let x: Int
    let y: Int

    func distance(from coordinate: Coordinate) -> Int {
        return abs(x - coordinate.x) + abs(y - coordinate.y)
    }
}

extension Coordinate {
    init(from data: Substring) {
        let parts = data.split(separator: ",")
        self.x = Int(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))!
        self.y = Int(parts[1].trimmingCharacters(in: .whitespacesAndNewlines))!
    }

    static func coordinates(from string: String) -> [Coordinate] {
        return string.split(separator: "\n").map(Coordinate.init)
    }
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "[\(x), \(y)]"
    }
}

extension Collection where Iterator.Element == Coordinate {
    var maxExtents: Coordinate? {
        let maxX = self.max { $0.x < $1.x }?.x
        let maxY = self.max { $0.y < $1.y }?.y
        guard let x = maxX, let y = maxY else { return nil }
        return Coordinate(x: x, y: y)
    }
}

struct Map {
    struct Info {
        var nearestPOI: [Coordinate]
        var distanceToNearest: Int
        var distanceSum: Int

        init() {
            nearestPOI = []
            distanceToNearest = Int.max
            distanceSum = Int.max
        }
    }

    let squares: [[Info]] // 2d matrix
    let poi: Set<Coordinate>
    let maxSum: Int

    init(pointsOfInterest: [Coordinate], maxSum: Int) {
        precondition(pointsOfInterest.isEmpty == false, "Must supply at least one POI")
        self.poi = Set(pointsOfInterest)
        self.maxSum = maxSum
        let extents = pointsOfInterest.maxExtents!
        var squares = Array(repeating: Array(repeating: Info(), count: extents.x + 1), count: extents.y + 1)
        for y in 0 ..< squares.count {
            let row = squares[y]
            for x in 0 ..< row.count {
                let coord = Coordinate(x: x, y: y)
                let distances = poi.map { point in (poi: point, distance: coord.distance(from: point)) }
                    .sorted { $0.distance < $1.distance }
                let closest = distances.first!
                squares[y][x].nearestPOI = distances.filter { $0.distance == closest.distance }.map { $0.poi }
                squares[y][x].distanceToNearest = closest.distance
                squares[y][x].distanceSum = distances.reduce(0) { $0 + $1.distance }
            }
        }
        self.squares = squares
    }

    func partOneSolution() -> Int {
        let candidateCoords = candidatePOI()
        let candidateAreas = candidateCoords.map(area)
        print(Array(zip(candidateCoords, candidateAreas)))
        return candidateAreas.max()!
    }

    func partTwoSolution() -> Int {
        return squares.flatMap { $0 }
            .filter { $0.distanceSum < maxSum }
            .count
    }

    // Gets the list of POI that do not have infinite area
    private func candidatePOI() -> Set<Coordinate> {
        var result = poi
        let extents = poi.maxExtents!
        // top row
        for y in 0 ... extents.y {
            let info = squares[y][0]
            if info.nearestPOI.count == 1 {
                result.remove(info.nearestPOI.first!)
            }
        }
        // bottom row
        for y in 0 ... extents.y {
            let info = squares[y][extents.x]
            if info.nearestPOI.count == 1 {
                result.remove(info.nearestPOI.first!)
            }
        }
        // left column
        for x in 0 ... extents.x {
            let info = squares[0][x]
            if info.nearestPOI.count == 1 {
                result.remove(info.nearestPOI.first!)
            }
        }
        // right column
        for x in 0 ... extents.x {
            let info = squares[extents.y][x]
            if info.nearestPOI.count == 1 {
                result.remove(info.nearestPOI.first!)
            }
        }
        return result
    }

    private func area(for coordinate: Coordinate) -> Int {
        return squares.flatMap { $0 }
            .filter { info in info.nearestPOI.count == 1 && info.nearestPOI.first! == coordinate }
            .count
    }
}

extension Map: CustomStringConvertible {
    var description: String {
        return squares.map { row in
            row.map { info in
//                switch info.nearestPOI.count {
//                case 0: return " "
//                case 1: return info.distanceToNearest == 0 ? "O" : "x"
//                default: return "\(info.nearestPOI.count)"
//                }
                if info.distanceToNearest == 0 {
                    return "O"
                } else {
                    return info.distanceSum < maxSum ? "#" : "."
                }
            }.joined(separator: " ")
        }.joined(separator: "\n")
    }
}

let coordinates = Coordinate.coordinates(from: challengeInput)
print(coordinates.maxExtents!)

let map = Map(pointsOfInterest: coordinates, maxSum: 10000)
//print(map)

print("Part 1:", map.partOneSolution())
print("Part 2:", map.partTwoSolution())

print("Done")
