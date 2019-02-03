//
//  main.swift
//  Day 20
//
//  Created by Peter Bohac on 2/2/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var north: Coordinate { return Coordinate(x: x, y: y - 1) }
    var south: Coordinate { return Coordinate(x: x, y: y + 1) }
    var west: Coordinate { return Coordinate(x: x - 1, y: y) }
    var east: Coordinate { return Coordinate(x: x + 1, y: y) }

    var description: String {
        return "\(x),\(y)"
    }

    static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func * (lhs: Coordinate, rhs: Int) -> Coordinate {
        return Coordinate(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

final class Room: Hashable {
    var coordinate: Coordinate
    weak var north: Room?
    weak var south: Room?
    weak var east: Room?
    weak var west: Room?

    var neighbors: [Room] {
        return [north, south, east, west].compactMap { $0 }
    }

    var hashValue: Int {
        return coordinate.hashValue
    }

    init(coordinate: Coordinate) {
        self.coordinate = coordinate
    }

    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
}

final class RoomLoader {
    let source: String
    var rooms: [Coordinate: Room] = [:]

    var start: Room {
        return rooms[Coordinate(x: 0, y: 0)]!
    }

    init(with string: String) {
        self.source = string
    }

    func walk() {
        var branches: [Room] = []
        var room: Room!
        source.forEach { char in
            switch char {
            case "^":
                room = Room(coordinate: Coordinate(x: 0, y: 0))
                rooms = [room.coordinate: room]

            case "N":
                let nextRoom = getRoom(for: room.coordinate.north)
                room.north = nextRoom
                nextRoom.south = room
                room = nextRoom

            case "S":
                let nextRoom = getRoom(for: room.coordinate.south)
                room.south = nextRoom
                nextRoom.north = room
                room = nextRoom

            case "E":
                let nextRoom = getRoom(for: room.coordinate.east)
                room.east = nextRoom
                nextRoom.west = room
                room = nextRoom

            case "W":
                let nextRoom = getRoom(for: room.coordinate.west)
                room.west = nextRoom
                nextRoom.east = room
                room = nextRoom

            case "(":
                branches.append(room)

            case ")":
                room = branches.popLast()!

            case "|":
                room = branches.last!

            case "$":
                break

            default:
                preconditionFailure("Unhandled")
            }
        }
    }

    private func getRoom(for coord: Coordinate) -> Room {
        if let room = rooms[coord] {
            return room
        } else {
            let room = Room(coordinate: coord)
            rooms[coord] = room
            return room
        }
    }
}

final class Map {
    enum Square: String {
        case wall = "#"
        case room = "."
        case verticalDoor = "|"
        case horizontalDoor = "-"
        case start = "X"
    }

    let squares: [[Square]]

    init(rooms: [Room]) {
        let max = Int(Double(rooms.count).squareRoot()) * 2 + 1
        var squares = Array(repeating: Array(repeating: Square.wall, count: max), count: max)
        let coords = rooms.map { $0.coordinate }
        let minX = coords.map { $0.x }.min()!
        let minY = coords.map { $0.y }.min()!
        let translation = Coordinate(x: -minX, y: -minY)
        rooms.forEach { room in
            let square = room.coordinate == Coordinate(x: 0, y: 0) ? Square.start : Square.room
            let mapCoord = (room.coordinate + translation) * 2 + Coordinate(x: 1, y: 1)
            squares[mapCoord.y][mapCoord.x] = square
            if room.north != nil {
                squares[mapCoord.north.y][mapCoord.north.x] = .horizontalDoor
            }
            if room.south != nil {
                squares[mapCoord.south.y][mapCoord.south.x] = .horizontalDoor
            }
            if room.east != nil {
                squares[mapCoord.east.y][mapCoord.east.x] = .verticalDoor
            }
            if room.west != nil {
                squares[mapCoord.west.y][mapCoord.west.x] = .verticalDoor
            }
        }
        self.squares = squares
    }

    func draw() {
        for (_, row) in squares.enumerated() {
            for (_, s) in row.enumerated() {
                print(s.rawValue, terminator: "")
            }
            print("")
        }
    }
}

typealias Path = [Room]

final class PathFinder {
    var paths: [Room: Path] = [:]

    var distanceToFarthestRoom: Int {
        return paths.values.map { $0.count }.max()!
    }

    var roomsPassingThru1000Doors: Int {
        return paths.values.map { $0.count }.filter { $0 >= 1000 }.count
    }

    func calculatePaths(from room: Room, with path: Path = []) {
        if let lastPathToRoom = paths[room] {
            if path.count <= lastPathToRoom.count {
                paths[room] = path
            }
        } else {
            paths[room] = path
        }
        room.neighbors.forEach { neighbor in
            if path.contains(neighbor) { return }
            calculatePaths(from: neighbor, with: path + [room])
        }
    }
}

let loader = RoomLoader(with: InputData.challenge)
loader.walk()

//let map = Map(rooms: Array(loader.rooms.values))
//map.draw()

let pathFinder = PathFinder()
pathFinder.calculatePaths(from: loader.start)
print("Distance:", pathFinder.distanceToFarthestRoom)
print("Rooms 1000 or more doors away:", pathFinder.roomsPassingThru1000Doors)

print("Done")
