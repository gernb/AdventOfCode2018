//
//  main.swift
//  Day 18
//
//  Created by Peter Bohac on 2/2/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Coordinate: Equatable, CustomStringConvertible {
    let x: Int
    let y: Int

    var up: Coordinate { return Coordinate(x: x, y: y - 1) }
    var down: Coordinate { return Coordinate(x: x, y: y + 1) }
    var left: Coordinate { return Coordinate(x: x - 1, y: y) }
    var right: Coordinate { return Coordinate(x: x + 1, y: y) }

    var upLeft: Coordinate { return Coordinate(x: x - 1, y: y - 1) }
    var upRight: Coordinate { return Coordinate(x: x + 1, y: y - 1) }
    var downLeft: Coordinate { return Coordinate(x: x - 1, y: y + 1) }
    var downRight: Coordinate { return Coordinate(x: x + 1, y: y + 1) }

    var allNeighbors: [Coordinate] {
        return [upLeft, up, upRight, left, right, downLeft, down, downRight]
    }

    var description: String {
        return "\(x),\(y)"
    }
}

final class Map {
    enum Acre: String, Equatable {
        case open = "."
        case trees = "|"
        case lumberyard = "#"
    }

    var land: [[Acre]]
    var elapsedMinutes = 0

    init(land: [[Acre]]) {
        self.land = land
    }

    subscript(x: Int, y: Int) -> Acre? {
        get {
            guard x >= 0 && y >= 0 && y < land.count && x < land[y].count else { return nil }
            return land[y][x]
        }
        set {
            guard let newValue = newValue else { return }
            guard x >= 0 && y >= 0 && y < land.count && x < land[y].count else { return }
            land[y][x] = newValue
        }
    }

    subscript(coord: Coordinate) -> Acre? {
        get { return self[coord.x, coord.y] }
        set { self[coord.x, coord.y] = newValue }
    }

    func neighboringLand(of coord: Coordinate) -> [Acre] {
        return coord.allNeighbors.map { self[$0] }.compactMap { $0 }
    }

    func neighboringLand(of x: Int, _ y: Int) -> [Acre] {
        return neighboringLand(of: Coordinate(x: x, y: y))
    }

    func draw() {
        print(land.map { row in row.map { $0.rawValue }.joined() }.joined(separator: "\n"))
    }
}

extension Map {
    static func load(from string: String) -> Map {
        let lines = string.split(separator: "\n")
        let maxY = lines.count
        let maxX = lines.map { $0.count }.max()!
        var land = Array(repeating: Array(repeating: Acre.open, count: maxX), count: maxY)
        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                switch char {
                case ".": break
                case "|": land[y][x] = .trees
                case "#": land[y][x] = .lumberyard
                default:
                    preconditionFailure("Unexpected character!")
                }
            }
        }
        return Map(land: land)
    }
}

extension Map {
    var woodedAcres: Int {
        return land.flatMap { $0 }.filter { $0 == .trees }.count
    }

    var lumberyards: Int {
        return land.flatMap { $0 }.filter { $0 == .lumberyard }.count
    }

    func advance() {
        let maxY = land.count
        let maxX = land[0].count
        var newState = Array(repeating: Array(repeating: Acre.open, count: maxX), count: maxY)
        for (y, row) in land.enumerated() {
            for (x, acre) in row.enumerated() {
                let neighbors = neighboringLand(of: x, y)
                switch acre {
                case .open:
                    newState[y][x] = neighbors.filter { $0 == .trees }.count >= 3 ? .trees : .open
                case .trees:
                    newState[y][x] = neighbors.filter { $0 == .lumberyard }.count >= 3 ? .lumberyard : .trees
                case .lumberyard:
                    let lumberyardCount = neighbors.filter { $0 == .lumberyard }.count
                    let treesCount = neighbors.filter { $0 == .trees }.count
                    newState[y][x] = lumberyardCount >= 1 && treesCount >= 1 ? .lumberyard : .open
                }
            }
        }
        elapsedMinutes += 1
        land = newState
    }
}

func partOneSolution(using string: String) {
    let map = Map.load(from: string)
    repeat {
        print("")
        map.draw()
        let trees = map.woodedAcres
        let lumberyards = map.lumberyards
        print("[\(map.elapsedMinutes)] \(trees) trees; \(lumberyards) lumberyards; score: \(trees * lumberyards)", terminator: "")
        _ = readLine()
        map.advance()
    } while true
}

func partTwoSolution(using string: String) {
    let map = Map.load(from: string)
    print("Finding first 1000 iterations...")
    let scores = (0 ..< 1000).map { _ -> Int in
        let score = map.woodedAcres * map.lumberyards
        map.advance()
        return score
    }
    print("Finding perodicity...")
    var startOffset: Int?
    var repeatLen: Int?
    let result = scores.map(String.init).joined(separator: ",")
    for len in (2 ..< (scores.count / 2)).reversed() {
        for offset in 0 ..< (scores.count - len) {
            let substring = scores.dropFirst(offset).prefix(len).map(String.init).joined(separator: ",")
            let firstIdx = result.range(of: substring)!.upperBound.encodedOffset
            let lastIdx = result.range(of: substring, options: .backwards)!.lowerBound.encodedOffset
            if lastIdx > firstIdx {
                startOffset = offset
                repeatLen = len
                break
            }
        }
        if startOffset != nil {
            break
        }
    }
    print("Repeating begins at \(startOffset!) and cycles every \(repeatLen!) minutes.")
    let scoreIndex = ((1_000_000_000 - startOffset!) % repeatLen!) + startOffset!
    print("Score at 1 billion:", scores[scoreIndex])
}

//partOneSolution(using: InputData.challenge)
partTwoSolution(using: InputData.challenge)
