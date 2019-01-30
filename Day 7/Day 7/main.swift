//
//  main.swift
//  Day 7
//
//  Created by Peter Bohac on 1/29/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

final class Step {
    let id: String
    var prerequisites: Set<Step>
    var complete: Bool

    var ready: Bool {
        return prerequisites.reduce(true) { $0 && $1.complete }
    }

    var duration: Int {
        return Int(id.first!.unicodeScalars.first!.value) - Int("A".first!.unicodeScalars.first!.value) + 1
    }

    init(id: Substring) {
        self.id = String(id)
        self.prerequisites = Set()
        self.complete = false
    }
}

extension Step: Equatable {
    static func == (lhs: Step, rhs: Step) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Step: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}

extension Step: CustomStringConvertible {
    var description: String {
        let string = "\(id): \(prerequisites.map { $0.id })"
        if complete {
            return string + " - Complete"
        } else if ready {
            return string + " - Ready"
        } else {
            return string
        }
    }
}

extension Step {
    static func steps(from input: String) -> [Step] {
        var steps: [Substring: Step] = [:]
        input.split(separator: "\n").forEach { line in
            let words = line.split(separator: " ")
            let prereqId = words[1]
            let stepId = words[7]
            let prereq = steps[prereqId] ?? Step(id: prereqId)
            let step = steps[stepId] ?? Step(id: stepId)
            step.prerequisites.insert(prereq)
            steps[prereqId] = prereq
            steps[stepId] = step
        }
        return Array(steps.values)
    }

    static func sortByReady(lhs: Step, rhs: Step) -> Bool {
        switch (lhs.ready, rhs.ready) {
        case (true, false): return true
        case (false, true): return false
        case (_, _): return lhs.id < rhs.id
        }
    }
}

func partOneSolution(_ steps: [Step]) -> String {
    var incomplete = steps
    var complete: [Step] = []

    while incomplete.isEmpty == false {
        let next = incomplete.sorted(by: Step.sortByReady).first!
        assert(next.ready, "Uh oh, no ready steps!")
        next.complete = true
        incomplete.remove(at: incomplete.firstIndex(of: next)!)
        complete.append(next)
    }

    return complete.map { $0.id }.joined()
}

final class Worker {
    let additionalDuration: Int
    var workingOn: Step?
    var busyUntil: Int = 0

    init(_ additionalDuration: Int) {
        self.additionalDuration = additionalDuration
    }

    func start(step: Step, at count: Int) {
        workingOn = step
        busyUntil = count + step.duration + additionalDuration
    }
}

extension Worker: CustomStringConvertible {
    var description: String {
        if let step = workingOn {
            return "Working on \(step.id) until \(busyUntil)"
        } else {
            return "Idle"
        }
    }
}

func partTwoSolution(_ steps: [Step], workerCount: Int, additionalDuration: Int) -> (String, Int) {
    var incomplete = steps
    var complete: [Step] = []
    var count = 0
    let workers = (0 ..< workerCount).map { _ in Worker(additionalDuration) }
    let totalSteps = steps.count

    while complete.count != totalSteps {
        // Check for complete work
        workers.forEach { worker in
            guard let step = worker.workingOn else { return }
            if worker.busyUntil == count {
                worker.workingOn = nil
                step.complete = true
                complete.append(step)
            }
        }
        // Start ready work
        workers.forEach { worker in
            guard worker.workingOn == nil else { return }
            guard let next = incomplete.sorted(by: Step.sortByReady).first, next.ready else { return }
            incomplete.remove(at: incomplete.firstIndex(of: next)!)
            worker.start(step: next, at: count)
        }
//        print(count, workers)
        count += 1
    }

    return (complete.map { $0.id }.joined(), count - 1)
}

let steps = Step.steps(from: challengeInput)
//print(steps)
//print(partOneSolution(steps))

print(partTwoSolution(steps, workerCount: 5, additionalDuration: 60))

print("Done.")
