//
//  main.swift
//  Day3
//
//  Created by Peter Bohac on 1/28/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

struct Claim {
    let id: String
    let origin: (x: Int, y: Int)
    let size: (width: Int, height: Int)

    init(string: Substring) {
        var parts = string.split(separator: "@").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        self.id = parts[0]
        parts = parts[1].split(separator: ":").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var numbers = parts[0].split(separator: ",").map { Int($0)! }
        self.origin.x = numbers[0]
        self.origin.y = numbers[1]
        numbers = parts[1].split(separator: "x").map { Int($0)! }
        self.size.width = numbers[0]
        self.size.height = numbers[1]
    }
}

extension Claim: CustomStringConvertible {
    var description: String {
        return "\(id) @ \(origin.x),\(origin.y): \(size.width)x\(size.height)"
    }
}

class Fabric {

    let size: Int
    var squareClaims: [[[Claim]]]

    init(size: Int) {
        self.size = size
        self.squareClaims = Array(repeating: Array(repeating: [], count: size), count: size)
    }

    func process(claims: [Claim]) {
        claims.forEach { claim in
            print("Processing claim \(claim.id) out of \(claims.count)")
            for x in claim.origin.x ..< (claim.origin.x + claim.size.width) {
                for y in claim.origin.y ..< (claim.origin.y + claim.size.height) {
                    var claimers = squareClaims[x][y]
                    claimers.append(claim)
                    squareClaims[x][y] = claimers
                }
            }
        }
    }

    func squaresWithMutipleClaims() -> Int {
        return squareClaims.flatMap { $0 }.filter { $0.count > 1 }.count
    }
}

extension Fabric: CustomStringConvertible {
    var description: String {
        return squareClaims.map { row in
            row.map { square in
                switch square.count {
                case 0: return "."
                case 1: return "o"
                default: return "X"
                }
                }.joined(separator: " ")
            }.joined(separator: "\n")
    }
}

let claims = realClaims.split(separator: "\n").map(Claim.init)
let fabric = Fabric(size: 1000)

//print(fabric)
//print("")
fabric.process(claims: claims)
print("Claims processed.")
//print(fabric)
print(fabric.squaresWithMutipleClaims())

extension Collection where Iterator.Element == Claim {
    func nonoverlapping(in fabric: Fabric) -> [Claim] {
        return self.filter { claim in
            for x in claim.origin.x ..< (claim.origin.x + claim.size.width) {
                for y in claim.origin.y ..< (claim.origin.y + claim.size.height) {
                    if fabric.squareClaims[x][y].count > 1 {
                        return false
                    }
                }
            }
            return true
        }
    }
}

print(claims.nonoverlapping(in: fabric))
