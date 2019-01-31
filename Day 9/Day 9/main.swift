//
//  main.swift
//  Day 9
//
//  Created by Bohac, Peter on 1/30/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

final class Node<T> {
    let value: T
    private(set) var next: Node! // clockwise
    private(set) var prev: Node! // counter-clockwise

    static func node(with value: T) -> Node {
        let node = Node(value: value)
        node.prev = node
        node.next = node
        return node
    }

    private init(value: T, prev: Node? = nil, next: Node? = nil) {
        self.value = value
        self.next = next
        self.prev = prev
    }

    // returns the newly inserted node
    func insert(value: T) -> Node {
        let node = Node(value: value, prev: self, next: self.next)
        self.next = node
        node.next.prev = node
        return node
    }

    // returns the node after the current node
    func remove() -> Node {
        let result = self.next!
        self.prev.next = result
        result.prev = self.prev
        return result
    }

    func deleteAll() {
        var node = self
        while node.next !== node {
            node = self.remove()
        }
        node.prev = nil
        node.next = nil
    }
}

final class Game {
    typealias Marble = Int

    let largestMarble: Marble
    let playerCount: Int
    var scores: [Int] = []
//    var circle: [Marble] = []
//    var currentMarbleIndex: Int = 0
    var circle = Node.node(with: 0)
    var currentPlayer: Int = 0

    init(playerCount: Int, largestMarble: Marble) {
        self.largestMarble = largestMarble
        self.playerCount = playerCount
    }

    deinit {
        circle.deleteAll()
    }

    // return the final scores
    func play() -> [Int] {
        reset()
        for marble in 1 ... largestMarble {
            if isMagicMultiple(marble: marble) {
                magicMultipleMove(with: marble)
            } else {
                normalMove(with: marble)
            }
//            print("[\(currentPlayer + 1)] Marble #\(marble) -> \(circle)")
            currentPlayer = (currentPlayer + 1) % playerCount
        }
        return scores
    }

    private func normalMove(with marble: Marble) {
//        let nextIndex = (currentMarbleIndex + 1) % circle.count + 1
//        circle.insert(marble, at: nextIndex)
//        currentMarbleIndex = nextIndex
        circle = circle.next
        circle = circle.insert(value: marble)
    }

    private func magicMultipleMove(with marble: Marble) {
//        var nextIndex = currentMarbleIndex - 7
//        if nextIndex < 0 {
//            nextIndex += circle.count
//        }
//        let marbleToRemove = circle[nextIndex]
//        circle.remove(at: nextIndex)
//        currentMarbleIndex = nextIndex

        (1 ... 7).forEach { _ in circle = circle.prev }
        let marbleToRemove = circle.value
        circle = circle.remove()

        scores[currentPlayer] += marble + marbleToRemove
    }

    private func reset() {
        scores = Array(repeating: 0, count: playerCount)
//        circle = [0]
//        circle.reserveCapacity(largestMarble)
//        currentMarbleIndex = 0
        circle.deleteAll()
        circle = Node.node(with: 0)
        currentPlayer = 0
    }

    private func isMagicMultiple(marble: Marble) -> Bool {
        return marble % 23 == 0
    }
}

//let game = Game(playerCount: 9, largestMarble: 25) // -> 32
//let game = Game(playerCount: 10, largestMarble: 1618) // 10 players; last marble is worth 1618 points: high score is 8317
//let game = Game(playerCount: 13, largestMarble: 7999) // 13 players; last marble is worth 7999 points: high score is 146373
//let game = Game(playerCount: 17, largestMarble: 1104) // 17 players; last marble is worth 1104 points: high score is 2764
//let game = Game(playerCount: 21, largestMarble: 6111) // 21 players; last marble is worth 6111 points: high score is 54718
//let game = Game(playerCount: 30, largestMarble: 5807) // 30 players; last marble is worth 5807 points: high score is 37305

//let game = Game(playerCount: 410, largestMarble: 72059) // 410 players; last marble is worth 72059 points

let game = Game(playerCount: 410, largestMarble: 7205900) // 410 players; last marble is worth 7205900 points

let scores = game.play()

print(scores)
print("Part 1:", scores.max()!)
