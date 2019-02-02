//
//  main.swift
//  Day 15
//
//  Created by Bohac, Peter on 2/1/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

// MARK: - Coordinate

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var up: Coordinate { return Coordinate(x: x, y: y - 1) }
    var down: Coordinate { return Coordinate(x: x, y: y + 1) }
    var left: Coordinate { return Coordinate(x: x - 1, y: y) }
    var right: Coordinate { return Coordinate(x: x + 1, y: y) }

    var description: String {
        return "\(x),\(y)"
    }

    static func areInReadingOrder(lhs: Coordinate, rhs: Coordinate) -> Bool {
        if lhs.y == rhs.y {
            return lhs.x < rhs.x
        } else {
            return lhs.y < rhs.y
        }
    }

    static func < (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return areInReadingOrder(lhs: lhs, rhs: rhs)
    }
}

// MARK: - Graph

struct Node<T> {
    let value: T
    let neighbors: [T]
}

final class Graph<T: Hashable> {
    var nodes: [T: Node<T>] = [:]
    var root: Node<T>?

    func add(_ node: Node<T>, using generate: (T) -> [T]) {
        guard nodes[node.value] == nil else { return }
        nodes[node.value] = node
        node.neighbors.forEach { value in
            let newNode = Node(value: value, neighbors: generate(value))
            add(newNode, using: generate)
        }
    }

    func distance(from: T, to: T) -> Int {
        guard nodes.keys.contains(from) && nodes.keys.contains(to) else {
            preconditionFailure("From and/or To not reachable!")
        }
        guard from != to else { return 0 }

        var distances: [T: Int] = [to: 0]
        var queue: [T] = []
        var current = to
        repeat {
            let distance = distances[current]! + 1
            let currentNode = nodes[current]!
            currentNode.neighbors.forEach { neighbor in
                if distances[neighbor] == nil {
                    distances[neighbor] = distance
                    queue.append(neighbor)
                }
            }
//            draw(distances)
            current = queue.removeFirst()
        } while current != from

        return distances[from]!
    }

//    private func draw(_ distances: [T: Int]) {
//        var matrix = Array(repeating: Array(repeating: ".", count: 9), count: 9)
//        distances.forEach { key, value in
//            let coord = key as! Coordinate
//            matrix[coord.y][coord.x] = String(value)
//        }
//        print(matrix.map { $0.joined() }.joined(separator: "\n"), "\n")
//    }
}

// MARK: - Player

enum PlayerType: String {
    case elf = "E"
    case goblin = "G"
}

protocol Player: CustomStringConvertible {
    var playerType: PlayerType { get }
    var position: Coordinate { get set }
    var hitPoints: Int { get set }
    var isAlive: Bool { get }
    var attackPower: Int { get }

    mutating func performTurn(in cavarn: Cavern)
    func isEnemy(_ other: Player) -> Bool
}

extension Player {
    var description: String {
        return playerType.rawValue
    }

    var isAlive: Bool {
        return hitPoints > 0
    }

    mutating func performTurn(in cavarn: Cavern) {
        guard isAlive else { return }

        if enemiesInRange(in: cavarn).count > 0 {
            attack(in: cavarn)
        } else {
            move(in: cavarn)
            if enemiesInRange(in: cavarn).count > 0 {
                attack(in: cavarn)
            }
        }
    }

    // MARK: Private Functions

    private func enemiesInRange(in cavarn: Cavern) -> [Player] {
        return [position.up, position.left, position.right, position.down].map { coord -> Player? in
            if let player = cavarn.contents(at: coord)?.player, isEnemy(player) {
                return player
            } else {
                return nil
            }
        }.compactMap { $0 }
    }

    private func enemies(in cavarn: Cavern) -> [Player] {
        return cavarn.activePlayers.filter { isEnemy($0) }
    }

    private mutating func move(in cavarn: Cavern) {
        let adjacentEmptySquares = cavarn.adjoiningSquares(of: position).filter { $0.square.isEmpty }
        guard adjacentEmptySquares.count > 0 else {
            // no empty squares to move in to, so bai out early
            return
        }
        let destinations = findDestinations(in: cavarn)
        guard destinations.count > 0 else {
            // nothing to move towards, so bail out early
            return
        }
//        cavarn.draw(with: destinations.map { ($0, Cavern.Square.custom("?")) })
//        print("")
        let graph = createGraph(with: cavarn)
        let reachableDestinations = destinations.filter { graph.nodes.keys.contains($0) }
        guard reachableDestinations.count > 0 else {
            // cannot actually get to any of the destinations, so bail out early
            return
        }
//        cavarn.draw(with: reachableDestinations.map { ($0, Cavern.Square.custom("@")) })
//        print("")
        let distancesToDestinations = reachableDestinations.map { destination -> (destination: Coordinate, distance: Int) in
            let distance = graph.distance(from: self.position, to: destination)
            return (destination, distance)
        }.sorted { $0.distance < $1.distance }
        let smallestDistance = distancesToDestinations.first!.distance
        let nearestDestinations = distancesToDestinations.prefix { $0.distance == smallestDistance }.map { $0.destination }
//        cavarn.draw(with: nearestDestinations.map { ($0, Cavern.Square.custom("!")) })
//        print("")
        let selectedDestination = nearestDestinations.sorted(by: Coordinate.areInReadingOrder).first!
//        cavarn.draw(with: [(selectedDestination, Cavern.Square.custom("+"))])
//        print("")
        let nextStep = findStepTowards(destination: selectedDestination, in: cavarn, with: graph)
        position = nextStep
//        cavarn.draw()
//        print("")
    }

    private func findDestinations(in cavarn: Cavern) -> [Coordinate] {
        let enemies = self.enemies(in: cavarn)
        return enemies.map { enemy in
            return [enemy.position.up, enemy.position.left, enemy.position.right, enemy.position.down].filter { coord in
                return cavarn.contents(at: coord)?.isEmpty ?? false
            }
        }.flatMap { $0 }
    }

    private func createGraph(with cavarn: Cavern) -> Graph<Coordinate> {
        func getNeighbors(of coord: Coordinate) -> [Coordinate] {
            return cavarn.adjoiningSquares(of: coord)
                .filter { $0.square.isEmpty || $0.position == position }
                .map { $0.position }
        }
        let root = Node(value: position, neighbors: getNeighbors(of: position))
        let graph = Graph<Coordinate>()
        graph.add(root, using: getNeighbors)
        graph.root = root
        return graph
    }

    private func findStepTowards(destination: Coordinate, in cavarn: Cavern, with graph: Graph<Coordinate>) -> Coordinate {
        let possibleSteps = cavarn.adjoiningSquares(of: position).filter { $0.square.isEmpty }.map { $0.position }
        if possibleSteps.count == 1 {
            return possibleSteps.first!
        } else {
            let distances = possibleSteps.map { position -> (Coordinate, Int)? in
                let distance = graph.distance(from: position, to: destination)
                return distance >= 0 ? (position, distance) : nil
                }.compactMap { $0 }.sorted { $0.1 < $1.1 }
            let smallestDistance = distances.first!.1
            return distances.prefix { $0.1 == smallestDistance }
                .map { $0.0 }
                .sorted(by: Coordinate.areInReadingOrder)
                .first!
        }
    }

    private mutating func attack(in cavarn: Cavern) {
        var target = enemiesInRange(in: cavarn)
            .sorted { $0.hitPoints == $1.hitPoints ? $0.position < $1.position : $0.hitPoints < $1.hitPoints }.first!
        target.hitPoints -= attackPower
    }
}

func arePlayersInReadingOrder(lhs: Player, rhs: Player) -> Bool {
    return lhs.position < rhs.position
}

final class Elf: Player {
    let playerType = PlayerType.elf
    var position: Coordinate
    var hitPoints: Int
    let attackPower: Int

    init(position: Coordinate, hitPoints: Int = 200, attackPower: Int = 3) {
        self.position = position
        self.hitPoints = hitPoints
        self.attackPower = attackPower
    }

    func isEnemy(_ other: Player) -> Bool {
        return other is Goblin
    }
}

final class Goblin: Player {
    let playerType = PlayerType.goblin
    var position: Coordinate
    var hitPoints: Int
    let attackPower = 3

    init(position: Coordinate, hitPoints: Int = 200) {
        self.position = position
        self.hitPoints = hitPoints
    }

    func isEnemy(_ other: Player) -> Bool {
        return other is Elf
    }
}

// MARK: - Cavarn

final class Cavern {
    typealias Map = [[Square]]

    enum Square: CustomStringConvertible {
        case empty
        case wall
        case player(Player)
        case custom(String)

        var isEmpty: Bool {
            if case .empty = self {
                return true
            } else {
                return false
            }
        }

        var player: Player? {
            if case .player(let p) = self {
                return p
            } else {
                return nil
            }
        }

        var description: String {
            switch self {
            case .empty: return "."
            case .wall: return "#"
            case .player(let p): return p.description
            case .custom(let s): return s
            }
        }
    }

    var map: Map // without players
    var players: [Player]
    var completedRoundsCount = 0

    var activePlayers: [Player] {
        return players.filter { $0.isAlive }
    }

    var mapWithPlayers: Map {
        var newMap = map
        activePlayers.forEach { p in newMap[p.position.y][p.position.x] = .player(p) }
        return newMap
    }

    var finished: Bool {
        let elfCount = activePlayers.filter { $0 is Elf }.count
        let goblinCount = activePlayers.filter { $0 is Goblin }.count
        return elfCount == 0 || goblinCount == 0
    }

    var score: Int {
        return completedRoundsCount * activePlayers.reduce(0) { $0 + $1.hitPoints }
    }

    var deadElves: Int {
        return players.filter { $0.isAlive == false && $0 is Elf }.count
    }

    var elvesWon: Bool {
        return deadElves == 0 && activePlayers.first is Elf
    }

    init(map: Map, players: [Player]) {
        self.map = map
        self.players = players
    }

    func contents(at coord: Coordinate) -> Square? {
        guard coord.x >= 0 && coord.y >= 0 && coord.y < map.count && coord.x < map[coord.y].count else { return nil }
        return mapWithPlayers[coord.y][coord.x]
    }

    func adjoiningSquares(of coord: Coordinate) -> [(square: Square, position: Coordinate)] {
        return [coord.up, coord.left, coord.right, coord.down].map { position -> (Square, Coordinate)? in
            if let square = contents(at: position) {
                return (square, position)
            } else {
                return nil
            }
        }.compactMap { $0 }
    }

    func performRound() {
        var sortedPlayers = activePlayers.sorted(by: arePlayersInReadingOrder)
        for index in (0 ..< sortedPlayers.count) {
            if finished { return }
            sortedPlayers[index].performTurn(in: self)
        }
        completedRoundsCount += 1
    }

    func run(pauseBetweenRounds: Bool = false, terminateWhenElfDies: Bool = false) {
        repeat {
            if pauseBetweenRounds {
                draw()
                print("Completed rounds: \(completedRoundsCount)", terminator: "")
                _ = readLine()
            } else {
                print(".", terminator: "")
            }
            performRound()

            if terminateWhenElfDies && deadElves > 0 {
                break
            }
        } while !finished
        if pauseBetweenRounds {
            draw()
            print("Completed rounds: \(completedRoundsCount)")
        }
    }
}

extension Cavern {
    static func load(from input: String, elfAttack: Int = 3) -> Cavern {
        let lines = input.split(separator: "\n")
        let maxY = lines.count
        let maxX = lines.map { $0.count }.max()!
        var map = Array(repeating: Array(repeating: Square.empty, count: maxX), count: maxY)
        var players = [Player]()

        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                let player: Player?
                (map[y][x], player) = parse(char, at: Coordinate(x: x, y: y), elfAttack: elfAttack)
                if let player = player {
                    players.append(player)
                }
            }
        }
        return Cavern(map: map, players: players)
    }

    private static func parse(_ char: Character, at coord: Coordinate, elfAttack: Int) -> (Square, Player?) {
        var player: Player?
        var square: Square
        switch char {
        case "#":
            square = .wall
        case ".":
            square = .empty
        case "E":
            square = .empty
            player = Elf(position: coord, attackPower: elfAttack)
        case "G":
            square = .empty
            player = Goblin(position: coord)
        default:
            preconditionFailure("Unexpected value (\(char)) at \(coord)")
        }
        return (square, player)
    }

    func draw(with replacements: [(pos: Coordinate, value: Square)] = []) {
        for (y, line) in mapWithPlayers.enumerated() {
            for (x, square) in line.enumerated() {
                let coord = Coordinate(x: x, y: y)
                if let replacement = replacements.first(where: { $0.pos == coord }) {
                    print(replacement.value, terminator: "")
                } else {
                    print(square, terminator: "")
                }
            }
            print("")
        }
    }
}

// Part 2 solution (brute force)
extension Cavern {
    static func findWinningElfAttack() {
        var cavern: Cavern
        var elfAttack = 10
        repeat {
            print("Running with elf attack:", elfAttack)
            cavern = Cavern.load(from: InputData.challenge, elfAttack: elfAttack)
            cavern.run(terminateWhenElfDies: true)
            print("")
            if cavern.elvesWon { break }
            elfAttack += 1
        } while true

        print("")
        cavern.draw()
        print("Score:", cavern.score)
    }
}

//let cavern = Cavern.load(from: InputData.challenge)
//cavern.run(pauseBetweenRounds: false)
//cavern.draw()
//print("Score:", cavern.score)

Cavern.findWinningElfAttack()
