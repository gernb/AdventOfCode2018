//
//  main.swift
//  Day 17
//
//  Created by Peter Bohac on 2/2/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

struct Coordinate: Equatable, CustomStringConvertible {
    let x: Int
    let y: Int

    var up: Coordinate { return Coordinate(x: x, y: y - 1) }
    var down: Coordinate { return Coordinate(x: x, y: y + 1) }
    var left: Coordinate { return Coordinate(x: x - 1, y: y) }
    var right: Coordinate { return Coordinate(x: x + 1, y: y) }

    var description: String {
        return "\(x),\(y)"
    }

    static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

final class GroundMap {
    enum Square: String {
        case clay = "#"
        case sand = "."
        case spring = "+"
        case flowingWater = "|"
        case stillWater = "~"

        var isClay: Bool {
            switch self {
            case .clay: return true
            default: return false
            }
        }

        var isSand: Bool {
            switch self {
            case .sand: return true
            default: return false
            }
        }

        var isStillWaterOrClay: Bool {
            switch self {
            case .clay, .stillWater: return true
            default: return false
            }
        }

        var isAnyWater: Bool {
            switch self {
            case .flowingWater, .stillWater: return true
            default: return false
            }
        }

        var isStillWater: Bool {
            switch self {
            case .stillWater: return true
            default: return false
            }
        }
    }

    var squares: [[Square]]

    var waterCount: Int {
        return squares.flatMap { $0 }
            .filter { $0.isAnyWater }
            .count
    }

    var stillWaterCount: Int {
        return squares.flatMap { $0 }
            .filter { $0.isStillWater }
            .count
    }

    init(squares: [[Square]]) {
        self.squares = squares
    }

    subscript(coord: Coordinate) -> Square? {
        get {
            guard coord.x >= 0 && coord.y >= 0 && coord.y < squares.count && coord.x < squares[coord.y].count else { return nil }
            return squares[coord.y][coord.x]
        }
        set {
            guard let newValue = newValue else { return }
            guard coord.x >= 0 && coord.y >= 0 && coord.y < squares.count && coord.x < squares[coord.y].count else { return }
            squares[coord.y][coord.x] = newValue
        }
    }

    func iterate() {
        for y in (0 ..< squares.count).reversed() {
            for (x, square) in squares[y].enumerated() {
                let pos = Coordinate(x: x, y: y)
                switch square {
                case .clay, .sand, .stillWater: break
                case .spring:
                    self[pos.down] = .flowingWater
                case .flowingWater:
                    moveFlowingWater(at: pos)
                }
            }
        }
    }

    private func moveFlowingWater(at coord: Coordinate) {
        guard let below = self[coord.down] else { return }
        switch below {
        case .sand, .flowingWater:
            self[coord.down] = .flowingWater
        case .clay, .stillWater:
            let walls = findWalls(coord)
            if let left = walls.left, let right = walls.right {
                for x in (left.x + 1) ..< right.x {
                    self[Coordinate(x: x, y: coord.y)] = .stillWater
                }
            } else {
                if let left = self[coord.left], left.isSand {
                    self[coord.left] = .flowingWater
                }
                if let right = self[coord.right], right.isSand {
                    self[coord.right] = .flowingWater
                }
            }
        case .spring:
            preconditionFailure("This should be impossible")
        }
    }

    private func findWalls(_ coord: Coordinate) -> (left: Coordinate?, right: Coordinate?) {
        var leftWall: Coordinate?
        var rightWall: Coordinate?

        // search left
        var left = coord.left
        while let square = self[left] {
            if square.isClay {
                leftWall = left
                break
            }
            if self[left.down]!.isStillWaterOrClay {
                left = left.left
            } else {
                leftWall = nil
                break
            }
        }
        // search right
        var right = coord.right
        while let square = self[right] {
            if square.isClay {
                rightWall = right
                break
            }
            if self[right.down]!.isStillWaterOrClay {
                right = right.right
            } else {
                rightWall = nil
                break
            }
        }

        return (leftWall, rightWall)
    }
}

extension GroundMap {
    static func load(data: String) -> GroundMap {
        var claySquares = [Coordinate]()
        data.split(separator: "\n").forEach { line in
            claySquares += parse(line: line)
        }

        let minX = claySquares.map { $0.x }.min()! - 1
        let maxX = claySquares.map { $0.x }.max()! + 1
        let minY = claySquares.map { $0.y }.min()! - 1
        let maxY = claySquares.map { $0.y }.max()! + 1
        let translation = Coordinate(x: -minX, y: -minY)

        var squares: [[Square]] = Array(repeating: Array(repeating: .sand, count: maxX - minX + 1), count: maxY - minY)
        claySquares.forEach { coord in
            let adjustedCoord = coord + translation
            squares[adjustedCoord.y][adjustedCoord.x] = .clay
        }
        let spring = Coordinate(x: 500 + translation.x, y: 0)
        squares[spring.y][spring.x] = .spring
        return GroundMap(squares: squares)
    }

    private static func parse(line: Substring) -> [Coordinate] {
        var squares = [Coordinate]()
        let parts = line.split(separator: ",")
        if parts[0].hasPrefix("x") {
            let x = Int(parts[0].dropFirst(2))!
            let yRange = makeRange(parts[1].dropFirst(3))
            for y in yRange {
                squares.append(Coordinate(x: x, y: y))
            }
        } else {
            let y = Int(parts[0].dropFirst(2))!
            let xRange = makeRange(parts[1].dropFirst(3))
            for x in xRange {
                squares.append(Coordinate(x: x, y: y))
            }
        }
        return squares
    }

    private static func makeRange(_ string: Substring) -> ClosedRange<Int> {
        let parts = string.split(separator: ".").map { Int($0)! }
        return parts[0] ... parts[1]
    }

    func draw() {
        squares.forEach { line in
            line.forEach { square in
                print(square.rawValue, terminator: "")
            }
            print("")
        }
    }
}

func partOneSolution() {
    var previousWater = -1
    repeat {
//        print("")
//        map.draw()
//        print("Score: \(map.waterCount)", terminator: "")
//        _ = readLine()
        print(".", terminator: "")
        map.iterate()
        let waterCount = map.waterCount
        if previousWater == waterCount {
            break
        }
        previousWater = waterCount
    } while true
//    map.draw()
    print("\nComplete with:", previousWater)
}

func partTwoSolution() {
    var previousWater = -1
    repeat {
        print(".", terminator: "")
        map.iterate()
        let waterCount = map.waterCount
        if previousWater == waterCount {
            break
        }
        previousWater = waterCount
    } while true
    //    map.draw()
    print("\nComplete with:", map.stillWaterCount)
}

let map = GroundMap.load(data: InputData.sample)
//partOneSolution()
partTwoSolution()

print("Done")
