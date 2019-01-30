//
//  File.swift
//  Day 7
//
//  Created by Peter Bohac on 1/29/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

let testInput = """
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""

let challengeInput = """
Step S must be finished before step G can begin.
Step E must be finished before step T can begin.
Step G must be finished before step A can begin.
Step P must be finished before step Z can begin.
Step L must be finished before step Z can begin.
Step F must be finished before step H can begin.
Step D must be finished before step Y can begin.
Step J must be finished before step Y can begin.
Step N must be finished before step O can begin.
Step R must be finished before step Y can begin.
Step Y must be finished before step W can begin.
Step U must be finished before step T can begin.
Step H must be finished before step W can begin.
Step T must be finished before step Z can begin.
Step Q must be finished before step B can begin.
Step O must be finished before step Z can begin.
Step K must be finished before step W can begin.
Step M must be finished before step C can begin.
Step A must be finished before step Z can begin.
Step C must be finished before step X can begin.
Step I must be finished before step V can begin.
Step V must be finished before step W can begin.
Step W must be finished before step X can begin.
Step Z must be finished before step B can begin.
Step X must be finished before step B can begin.
Step D must be finished before step M can begin.
Step S must be finished before step Z can begin.
Step A must be finished before step B can begin.
Step V must be finished before step Z can begin.
Step Q must be finished before step Z can begin.
Step O must be finished before step W can begin.
Step S must be finished before step E can begin.
Step L must be finished before step B can begin.
Step P must be finished before step Y can begin.
Step K must be finished before step M can begin.
Step W must be finished before step Z can begin.
Step Y must be finished before step Q can begin.
Step J must be finished before step M can begin.
Step U must be finished before step H can begin.
Step Y must be finished before step U can begin.
Step D must be finished before step A can begin.
Step C must be finished before step V can begin.
Step G must be finished before step J can begin.
Step O must be finished before step C can begin.
Step P must be finished before step H can begin.
Step M must be finished before step B can begin.
Step T must be finished before step C can begin.
Step A must be finished before step W can begin.
Step C must be finished before step B can begin.
Step Q must be finished before step I can begin.
Step O must be finished before step A can begin.
Step N must be finished before step H can begin.
Step Q must be finished before step C can begin.
Step G must be finished before step W can begin.
Step V must be finished before step X can begin.
Step A must be finished before step V can begin.
Step S must be finished before step C can begin.
Step O must be finished before step M can begin.
Step E must be finished before step L can begin.
Step D must be finished before step V can begin.
Step P must be finished before step N can begin.
Step O must be finished before step I can begin.
Step P must be finished before step K can begin.
Step N must be finished before step A can begin.
Step A must be finished before step X can begin.
Step L must be finished before step A can begin.
Step L must be finished before step T can begin.
Step I must be finished before step X can begin.
Step N must be finished before step C can begin.
Step N must be finished before step W can begin.
Step Y must be finished before step M can begin.
Step R must be finished before step A can begin.
Step O must be finished before step X can begin.
Step G must be finished before step T can begin.
Step S must be finished before step P can begin.
Step E must be finished before step M can begin.
Step E must be finished before step A can begin.
Step E must be finished before step W can begin.
Step F must be finished before step D can begin.
Step U must be finished before step C can begin.
Step R must be finished before step Z can begin.
Step A must be finished before step C can begin.
Step F must be finished before step K can begin.
Step L must be finished before step V can begin.
Step F must be finished before step T can begin.
Step W must be finished before step B can begin.
Step Y must be finished before step A can begin.
Step D must be finished before step T can begin.
Step S must be finished before step V can begin.
Step Y must be finished before step O can begin.
Step K must be finished before step B can begin.
Step N must be finished before step V can begin.
Step Y must be finished before step I can begin.
Step Z must be finished before step X can begin.
Step E must be finished before step B can begin.
Step P must be finished before step O can begin.
Step D must be finished before step R can begin.
Step Q must be finished before step X can begin.
Step E must be finished before step K can begin.
Step J must be finished before step R can begin.
Step L must be finished before step N can begin.
"""
