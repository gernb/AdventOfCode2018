//
//  main.swift
//  Day4
//
//  Created by Peter Bohac on 1/28/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

import Foundation

enum Event {
    case shiftBegins(id: Int, timestamp: Date)
    case fallsAsleep(timestamp: Date)
    case wakesUp(timestamp: Date)

    var timestamp: Date {
        switch self {
        case .shiftBegins(_, let date): return date
        case .fallsAsleep(let date): return date
        case .wakesUp(let date): return date
        }
    }

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "'['yyyy-MM-dd HH:mm']'"
        return formatter
    }

    init(string: Substring) {
        let dateString = string.prefix(18)
        let timestamp = Event.dateFormatter.date(from: String(dateString))!
        let log = string.dropFirst(19)
        if log.starts(with: "falls asleep") {
            self = .fallsAsleep(timestamp: timestamp)
        } else if log.starts(with: "wakes up") {
            self = .wakesUp(timestamp: timestamp)
        } else /* Guard #X begins shift */ {
            let words = log.split(separator: " ")
            let idString = words[1].dropFirst()
            self = .shiftBegins(id: Int(idString)!, timestamp: timestamp)
        }
    }
}

struct SleepRecord {
    let guardId: Int
    var events: [Event] = []

    var minutesAsleep: Int {
        var totalMinutes = 0
        var beginTimestamp = Date()
        events.forEach { event in
            switch event {
            case .fallsAsleep(let date):
                beginTimestamp = date
            case .wakesUp(let date):
                let minutes = date.timeIntervalSince(beginTimestamp) / 60.0
                totalMinutes += Int(minutes)
            case .shiftBegins:
                preconditionFailure("Invalid event")
            }
        }
        return totalMinutes
    }

    var sleepiestMinute: (minute: Int, count: Int) {
        var minutesCount: [Int] = Array(repeating: 0, count: 60)
        var beginTimestamp = Date()
        events.forEach { event in
            switch event {
            case .fallsAsleep(let date):
                beginTimestamp = date
            case .wakesUp(let date):
                for minute in minutesRange(begin: beginTimestamp, end: date) {
                    minutesCount[minute] += 1
                }
            case .shiftBegins:
                preconditionFailure("Invalid event")
            }
        }
        let max = minutesCount.max()!
        return (minutesCount.firstIndex(of: max)!, max)
    }

    init(guardId: Int) {
        self.guardId = guardId
    }

    mutating func add(event: Event) {
        events.append(event)
    }

    static func records(from events: [Event]) -> [SleepRecord] {
        var sleepRecords: [Int: SleepRecord] = [:]
        var currentGuard = 0
        events.forEach { event in
            switch event {
            case .shiftBegins(let id, _):
                currentGuard = id
            case .fallsAsleep, .wakesUp:
                var record = sleepRecords[currentGuard] ?? SleepRecord(guardId: currentGuard)
                record.add(event: event)
                sleepRecords[currentGuard] = record
            }
        }
        return Array(sleepRecords.values)
    }

    private func minutesRange(begin: Date, end: Date) -> Range<Int> {
        let dateString = Event.dateFormatter.string(from: begin)
        let minutesStart = Int(dateString.dropLast().suffix(2))!
        let minutesCount = Int(end.timeIntervalSince(begin) / 60.0)
        return minutesStart ..< (minutesStart + minutesCount)
    }
}

//let foo = Event(string: "[1518-11-01 00:00] Guard #10 begins shift")
let events = input.split(separator: "\n").map(Event.init).sorted { $0.timestamp < $1.timestamp }
let sleepRecords = SleepRecord.records(from: events).sorted { $0.minutesAsleep > $1.minutesAsleep }

let sleepiestGuard = sleepRecords.first!
print(sleepiestGuard.guardId)
print(sleepiestGuard.sleepiestMinute)
print(sleepiestGuard.guardId * sleepiestGuard.sleepiestMinute.minute)

print("======")

let frequencyGuard = sleepRecords.sorted { $0.sleepiestMinute.count > $1.sleepiestMinute.count }.first!
print(frequencyGuard.guardId)
print(frequencyGuard.sleepiestMinute)
print(frequencyGuard.guardId * frequencyGuard.sleepiestMinute.minute)

print("Done")
