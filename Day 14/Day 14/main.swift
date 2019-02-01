//
//  main.swift
//  Day 14
//
//  Created by Peter Bohac on 1/31/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Scoreboard {
    var scores: [Int]
    var indexElf1: Int
    var indexElf2: Int

    init(capacity: Int) {
        self.scores = [3, 7]
        self.scores.reserveCapacity(capacity)
        self.indexElf1 = 0
        self.indexElf2 = 1
    }

    mutating func makeRecipes() {
        var sum = scores[indexElf1] + scores[indexElf2]
        if sum >= 10 {
            // 2 recipes are created
            scores.append(1)
            sum -= 10
        }
        scores.append(sum)

        // advance the elves' positions
        var advanceBy = 1 + scores[indexElf1]
        indexElf1 = (indexElf1 + advanceBy) % scores.count
        advanceBy = 1 + scores[indexElf2]
        indexElf2 = (indexElf2 + advanceBy) % scores.count
    }
}

extension Scoreboard: CustomStringConvertible {
    var description: String {
        return scores.map { String($0) }.joined()
    }
}

// part one solution
extension Scoreboard {
    mutating func scoresAfter(first num: Int) -> String {
        repeat {
            makeRecipes()
        } while scores.count < (num + 10)

        return scores.dropFirst(num)
            .prefix(10)
            .map { String($0) }
            .joined()
    }
}

// part two solution (brute force)
extension Scoreboard {
    mutating func recipesToMake(for string: String) -> Int {
        repeat {
            makeRecipes()
        } while scores.count < 50_000_000
        if let range = description.range(of: string) {
            return range.lowerBound.encodedOffset
        } else {
            return -1
        }
    }
}

var scoreboard = Scoreboard(capacity: 1_000_000)

//print(scoreboard)
//(1 ... 10).forEach { _ in
//    scoreboard.makeRecipies()
//    print(scoreboard)
//}

//print("9:", scoreboard.scoresAfter(first: 9)) // -> 5158916779
//print("5:", scoreboard.scoresAfter(first: 5)) // -> 0124515891
//print("18:", scoreboard.scoresAfter(first: 18)) // -> 9251071085
//print("2018:", scoreboard.scoresAfter(first: 2018)) // -> 5941429882

print("846021:", scoreboard.scoresAfter(first: 846021)) // -> ?

print(scoreboard.recipesToMake(for: "846021"))

print("Done!")
