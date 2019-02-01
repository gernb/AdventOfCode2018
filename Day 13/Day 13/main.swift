//
//  main.swift
//  Day 13
//
//  Created by Bohac, Peter on 1/31/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

final class Map {

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
    }

    enum Square: CustomStringConvertible {
        case empty
        case vertical(top: Coordinate, bottom: Coordinate)
        case horizontal(left: Coordinate, right: Coordinate)
        case rightCurve(end1: Coordinate, end2: Coordinate)
        case leftCurve(end1: Coordinate, end2: Coordinate)
        case junction(left: Coordinate, top: Coordinate, right: Coordinate, bottom: Coordinate)

        var description: String {
            switch self {
            case .vertical: return "|"
            case .horizontal: return "-"
            case .rightCurve: return "/"
            case .leftCurve: return "\\"
            case .junction: return "+"
            case .empty: return " "
            }
        }
    }

    final class Cart: CustomStringConvertible {
        enum Heading: String {
            case right = ">"
            case left = "<"
            case up = "^"
            case down = "v"
        }
        enum Direction: CaseIterable {
            case left, straight, right
        }

        var heading: Heading
        var position: Coordinate

        private var nextTurnIndex: Int
        var nextTurn: Direction {
            return Direction.allCases[nextTurnIndex]
        }

        var nextPosition: Coordinate {
            switch heading {
            case .right: return position.right
            case .left: return position.left
            case .up: return position.up
            case .down: return position.down
            }
        }

        var description: String {
            return heading.rawValue
        }

        init(heading: Heading, position: Coordinate) {
            self.heading = heading
            self.position = position
            self.nextTurnIndex = 0
        }

        func turnLeft() {
            switch heading {
            case .right: heading = .up
            case .left: heading = .down
            case .up: heading = .left
            case .down: heading = .right
            }
        }

        func turnRight() {
            switch heading {
            case .right: heading = .down
            case .left: heading = .up
            case .up: heading = .right
            case .down: heading = .left
            }
        }

        func incrementNextTurn() {
            nextTurnIndex = (nextTurnIndex + 1) % Direction.allCases.count
        }
    }

    enum TickStatus {
        case allGood
        case crash(Coordinate)

        var success: Bool {
            if case .allGood = self {
                return true
            } else {
                return false
            }
        }

        var position: Coordinate? {
            if case .crash(let c) = self {
                return c
            } else {
                return nil
            }
        }
    }

    let squares: [[Square]]
    var carts: [Cart]
    var tickCount: Int

    init(squares: [[Square]], carts: [Cart]) {
        self.squares = squares
        self.carts = carts
        self.tickCount = 0
    }

    func tick() -> TickStatus {
        carts.sort { lhs, rhs in
            if lhs.position.y == rhs.position.y {
                return lhs.position.x < rhs.position.x
            } else {
                return lhs.position.y < rhs.position.y
            }
        }

        tickCount += 1

        for (_, cart) in carts.enumerated() {
            move(cart)
            if carts.at(cart.position).count > 1 {
                return .crash(cart.position)
            }
        }

        return .allGood
    }

    private func move(_ cart: Cart) {
        guard let nextSquare = Map.getSquare(in: squares, at: cart.nextPosition) else {
            preconditionFailure("Cart left the map!!")
        }
        switch nextSquare {
        case .vertical, .horizontal:
            cart.position = cart.nextPosition
        case .junction:
            handleJunction(with: cart)
        case .leftCurve(let end1, let end2):
            handleCurve(with: cart, endPoint1: end1, endPoint2: end2)
        case .rightCurve(let end1, let end2):
            handleCurve(with: cart, endPoint1: end1, endPoint2: end2)
        case .empty:
            preconditionFailure("Cart left the track!!")
        }
    }

    private func handleJunction(with cart: Cart) {
        cart.position = cart.nextPosition
        switch cart.nextTurn {
        case .left:
            cart.turnLeft()
        case .straight:
            break
        case .right:
            cart.turnRight()
        }
        cart.incrementNextTurn()
    }

    private func handleCurve(with cart: Cart, endPoint1: Coordinate, endPoint2: Coordinate) {
        let positionOfCurve = cart.nextPosition
        assert(cart.position == endPoint1 || cart.position == endPoint2)
        let positionAfterCurve = cart.position == endPoint1 ? endPoint2 : endPoint1
        cart.position = cart.nextPosition
        switch positionAfterCurve {
        case positionOfCurve.up: cart.heading = .up
        case positionOfCurve.right: cart.heading = .right
        case positionOfCurve.down: cart.heading = .down
        case positionOfCurve.left: cart.heading = .left
        default:
            preconditionFailure("Danger Will Robinson!")
        }
    }
}

extension Map {
    static func load(from filename: String) -> Map {
        let pwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let inputFileUrl = pwd.appendingPathComponent(filename)
        let input = try! String(contentsOf: inputFileUrl)
        let lines = input.split(separator: "\n")
        let maxY = lines.count
        let maxX = lines.map { $0.count }.max()!

        var squares = Array(repeating: Array(repeating: Square.empty, count: maxX), count: maxY)
        var carts = [Cart]()
        var x = 0, y = 0
        lines.forEach { line in
            line.forEach { char in
                let cart: Cart?
                (squares[y][x], cart) = parse(char, at: x, y, with: squares)
                if let cart = cart {
                    carts.append(cart)
                }
                x += 1
            }
            y += 1
            x = 0
        }

        return Map(squares: squares, carts: carts)
    }

    private static func parse(_ char: Character, at x: Int, _ y: Int, with squares: [[Square]]) -> (Square, Cart?) {
        let coord = Coordinate(x: x, y: y)
        let square: Square
        let cart: Cart?

        switch char {
        case "|":
            square = .vertical(top: coord.up, bottom: coord.down)
            cart = nil
        case "-":
            square = .horizontal(left: coord.left, right: coord.right)
            cart = nil
        case "/":
            cart = nil
            guard let leftSquare = getSquare(in: squares, at: coord.left) else {
                square = .rightCurve(end1: coord.down, end2: coord.right)
                break
            }
            switch leftSquare {
            case .empty, .vertical:
                square = .rightCurve(end1: coord.down, end2: coord.right)
            case .horizontal, .junction:
                square = .rightCurve(end1: coord.up, end2: coord.left)
            case .leftCurve(_, let end2):
                square = coord == end2 ? .rightCurve(end1: coord.up, end2: coord.left) : .rightCurve(end1: coord.down, end2: coord.right)
            case .rightCurve:
                preconditionFailure("Invalid track layout")
            }
        case "\\":
            cart = nil
            guard let leftSquare = getSquare(in: squares, at: coord.left) else {
                square = .leftCurve(end1: coord.up, end2: coord.right)
                break
            }
            switch leftSquare {
            case .empty, .vertical:
                square = .leftCurve(end1: coord.up, end2: coord.right)
            case .horizontal, .junction:
                square = .leftCurve(end1: coord.down, end2: coord.left)
            case .rightCurve(_, let end2):
                square = coord == end2 ? .leftCurve(end1: coord.down, end2: coord.left) : .leftCurve(end1: coord.up, end2: coord.right)
            case .leftCurve:
                preconditionFailure("Invalid track layout")
            }
        case "+":
            square = .junction(left: coord.left, top: coord.up, right: coord.right, bottom: coord.down)
            cart = nil
        case "<":
            square = .horizontal(left: coord.left, right: coord.right)
            cart = Cart(heading: .left, position: coord)
        case ">":
            square = .horizontal(left: coord.left, right: coord.right)
            cart = Cart(heading: .right, position: coord)
        case "^":
            square = .vertical(top: coord.up, bottom: coord.down)
            cart = Cart(heading: .up, position: coord)
        case "v":
            square = .vertical(top: coord.up, bottom: coord.down)
            cart = Cart(heading: .down, position: coord)
        case " ":
            square = .empty
            cart = nil
        default:
            preconditionFailure("Unexpected character")
        }
        return (square, cart)
    }

    private static func getSquare(in squares: [[Square]], at coord: Coordinate) -> Square? {
        guard coord.y < squares.count && coord.y >= 0 &&
            coord.x < squares[coord.y].count && coord.x >= 0 else { return nil }
        return squares[coord.y][coord.x]
    }
}

extension Collection where Iterator.Element == Map.Cart {
    func at(_ coord: Map.Coordinate) -> [Map.Cart] {
        return self.filter { $0.position == coord }
    }

    func at(_ x: Int, _ y: Int) -> [Map.Cart] {
        return at(Map.Coordinate(x: x, y: y))
    }
}

extension Array where Element == Map.Cart {
    mutating func remove(_ cart: Map.Cart) {
        guard let index = self.firstIndex(where: { $0 === cart }) else { return }
        self.remove(at: index)
    }
}

extension Map {
    func draw() {
        for (y, line) in squares.enumerated() {
            for (x, square) in line.enumerated() {
                let carts = self.carts.at(x, y)
                switch carts.count {
                case 0:
                    print(square, terminator: "")
                case 1:
                    print(carts.first!, terminator: "")
                default:
                    print("X", terminator: "")
                }
            }
            print("")
        }
    }
}

extension Map {
    func tick2() {
        carts.sort { lhs, rhs in
            if lhs.position.y == rhs.position.y {
                return lhs.position.x < rhs.position.x
            } else {
                return lhs.position.y < rhs.position.y
            }
        }

        tickCount += 1

        for (_, cart) in carts.enumerated() {
            move(cart)
            let cartsSharingSquare = carts.at(cart.position)
            if cartsSharingSquare.count > 1 {
                // remove crashed carts
                cartsSharingSquare.forEach { carts.remove($0) }
            }
        }
    }
}

let map = Map.load(from: "ChallengeInput.txt")

func partOneSolution() {
    var result: Map.TickStatus
    repeat {
//        map.draw()
//        print("Tick...", terminator: "")
////        _ = readLine()
//        print("")
        result = map.tick()
    } while result.success
    map.draw()
    print("Crash at \(result.position!)")
}

//partOneSolution()

func partTwoSolution() {
    repeat {
//        map.draw()
//        print("Tick...")
        print(map.carts.count)
        map.tick2()
    } while map.carts.count > 1
    map.draw()
    print(map.carts.first!.position)
}

partTwoSolution()

print("Done!")
