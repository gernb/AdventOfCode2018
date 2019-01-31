//
//  main.swift
//  Day 8
//
//  Created by Bohac, Peter on 1/30/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

final class Node {
    let children: [Node]
    let metadata: [Int]

    init(children: [Node], metadata: [Int]) {
        self.children = children
        self.metadata = metadata
    }

    private var length: Int {
        return 2 /* header */ + children.reduce(0) { $0 + $1.length } + metadata.count
    }
}

extension Node {

    static func parse(_ data: String) -> Node {
        let values = data.split(separator: " ").map { Int(String($0))! }
        return Node(values: values.dropFirst(0))
    }

    private convenience init(values: ArraySlice<Int>) {
        var data = values
        let childCount = data.popFirst()!
        let metadataCount = data.popFirst()!
        let children = (0 ..< childCount).map { _ -> Node in
            let child = Node(values: data)
            data = data.dropFirst(child.length)
            return child
        }
        let metadata = data.prefix(metadataCount)
        self.init(children: children, metadata: Array(metadata))
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        return "Child count: \(children.count); Metadata: \(metadata); Value: \(value)"
    }
}

// Part One solution
extension Node {
    var checksum: Int {
        return metadata.reduce(0, +) + children.reduce(0) { $0 + $1.checksum }
    }
}

// Part Two solution
extension Node {
    var value: Int {
        if children.isEmpty {
            return metadata.reduce(0, +)
        } else {
            return metadata.reduce(0) { sum, childNumber in
                let index = childNumber - 1
                let childValue = (index >= 0) && (index < children.count) ? children[index].value : 0
                return sum + childValue
            }
        }
    }

    func dump(withIndent indent: String = "") {
        print(indent + description)
        children.forEach { $0.dump(withIndent: indent + " ") }
    }
}

let root = Node.parse(challengeInput)
print("Part 1:", root.checksum)
print("Part 2:", root.value)

//root.dump()

print("Done.")
