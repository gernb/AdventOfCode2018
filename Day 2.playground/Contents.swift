import Foundation

let boxIDs = realInput.split(separator: "\n")

func charCount(_ input: String.SubSequence) -> NSCountedSet {
    return NSCountedSet(array: Array(input))
}

func repeatCount(_ input: NSCountedSet) -> (two: Bool, three: Bool) {
    var hasTwo = false
    var hasThree = false
    for entry in input {
        if input.count(for: entry) == 2 {
            hasTwo = true
        }
        if input.count(for: entry) == 3 {
            hasThree = true
        }
    }
    return (hasTwo, hasThree)
}

func checksum(for input: [String.SubSequence]) -> Int {
    var hasTwoCount = 0
    var hasThreeCount = 0

    input.forEach { id in
        let counts = repeatCount(charCount(id))
        if counts.two {
            hasTwoCount += 1
        }
        if counts.three {
            hasThreeCount += 1
        }
    }
    return hasTwoCount * hasThreeCount
}

//checksum(for: boxIDs)

// ====== Part 2 ======

func compare(_ left: String.SubSequence, _ right: String.SubSequence) -> Bool {
    guard left.count == right.count else { return false }

    var differences = 0
    for (idx, leftChar) in left.enumerated() {
        let index = right.index(right.startIndex, offsetBy: idx)
        let rightChar = right[index]
        if leftChar != rightChar {
            differences += 1
        }
        if differences > 1 {
            return false
        }
    }
    return true
}

func findMatches(in input: [String.SubSequence]) -> (String.SubSequence, String.SubSequence)? {

    for (idx, boxId) in input.enumerated() {
        for (idx2, boxId2) in input[(idx + 1)...].enumerated() {
            if compare(boxId, boxId2) {
                return (boxId, boxId2)
            }
        }
    }
    return nil
}

findMatches(in: boxIDs)
