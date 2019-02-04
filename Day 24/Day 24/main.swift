//
//  main.swift
//  Day 24
//
//  Created by Peter Bohac on 2/3/19.
//  Copyright © 2019 Peter Bohac. All rights reserved.
//

enum AttackType: String {
    case fire, slashing, cold, bludgeoning, radiation
}

final class Group {
    var units: Int
    let hitPointsPerUnit: Int
    let attackType: AttackType
    let attackDamage: Int
    let initiative: Int
    let weakness: Set<AttackType>
    let immunity: Set<AttackType>

    var target: Group?

    var effectivePower: Int {
        return units * attackDamage
    }

    init(units: Int,
         hitPointsPerUnit: Int,
         attackType: AttackType,
         attackDamage: Int,
         initiative: Int,
         weakness: [AttackType],
         immunity: [AttackType]) {

        self.units = units
        self.hitPointsPerUnit = hitPointsPerUnit
        self.attackType = attackType
        self.attackDamage = attackDamage
        self.initiative = initiative
        self.weakness = Set(weakness)
        self.immunity = Set(immunity)
    }
}

extension Group {
    /// 17 units each with 5390 hit points (weak to radiation, bludgeoning)
    /// with an attack that does 4507 fire damage at initiative 2
    convenience init(with string: Substring, boost: Int = 0) {
        var words = string.split(separator: " ")
        let units = Int(words.removeFirst())!
        words.removeFirst(3)
        let hitPoints = Int(words.removeFirst())!
        words.removeFirst(2)
        var modifierWords: [Substring] = []
        if words.first!.hasPrefix("(") {
            while words.first!.hasSuffix(")") == false {
                modifierWords.append(words.removeFirst())
            }
            modifierWords.append(words.removeFirst())
        }
        words.removeFirst(5)
        let damage = Int(words.removeFirst())! + boost
        let attackType = AttackType(rawValue: String(words.removeFirst()))!
        words.removeFirst(3)
        let initiative = Int(words.removeFirst())!

        var weakness: [AttackType] = []
        var immunity: [AttackType] = []
        if modifierWords.isEmpty == false {
            var parsingWeakness = true
            modifierWords
                .map { word -> Substring in
                    if word.hasPrefix("(") { return word.dropFirst() }
                    else if word.hasSuffix(",") || word.hasSuffix(";") || word.hasSuffix(")") { return word.dropLast() }
                    else { return word }
                }
                .forEach { word in
                    if word == "weak" {
                        parsingWeakness = true
                    } else if word == "immune" {
                        parsingWeakness = false
                    } else if word == "to" {
                        return
                    } else {
                        let attackType = AttackType(rawValue: String(word))!
                        if parsingWeakness { weakness.append(attackType) }
                        else { immunity.append(attackType) }
                    }
                }
        }

        self.init(units: units,
                  hitPointsPerUnit: hitPoints,
                  attackType: attackType,
                  attackDamage: damage,
                  initiative: initiative,
                  weakness: weakness,
                  immunity: immunity)
    }
}

extension Group {
    static func areInSelectionOrder(lhs: Group, rhs: Group) -> Bool {
        if lhs.effectivePower == rhs.effectivePower {
            return lhs.initiative > rhs.initiative
        } else {
            return lhs.effectivePower > rhs.effectivePower
        }
    }

    func selectTarget(from groups: inout [Group]) {
        let targets = groups.map { group in
            return (group, attack(group: group))
        }.filter { $0.1 > 0 }
        .sorted { lhs, rhs in
            if lhs.1 == rhs.1 {
                return Group.areInSelectionOrder(lhs: lhs.0, rhs: rhs.0)
            } else {
                return lhs.1 > rhs.1
            }
        }
        if let foundTarget = targets.first?.0 {
            target = foundTarget
            groups.removeAll { $0 === foundTarget }
        }
    }

    func attack(group: Group) -> Int {
        if group.immunity.contains(attackType) {
            return 0
        } else if group.weakness.contains(attackType) {
            return effectivePower * 2
        } else {
            return effectivePower
        }
    }

    @discardableResult
    func takeDamage(_ damage: Int) -> Int {
        let startingUnits = units
        let remainingHP = (units * hitPointsPerUnit) - damage
        if remainingHP <= 0 {
            units = 0
        } else {
            units = remainingHP / hitPointsPerUnit
            if remainingHP % hitPointsPerUnit != 0 {
                units += 1
            }
        }
        return startingUnits - units
    }
}

final class Battle {
    var immuneSystem: [Group] = []
    var infection: [Group] = []

    var immuneSystemUnits: Int {
        return immuneSystem.reduce(0) { $0 + $1.units }
    }

    var infectionUnits: Int {
        return infection.reduce(0) { $0 + $1.units }
    }

    var immuneSystemDidWin: Bool {
        return immuneSystem.count > 0
    }

    init(with string: String, boost: Int) {
        var isParsingImmuneSystem = true
        string.split(separator: "\n").forEach { line in
            if line.hasPrefix("Immune System") {
                isParsingImmuneSystem = true
            } else if line.hasPrefix("Infection") {
                isParsingImmuneSystem = false
            } else {
                if isParsingImmuneSystem {
                    let group = Group(with: line, boost: boost)
                    immuneSystem.append(group)
                } else {
                    let group = Group(with: line)
                    infection.append(group)
                }
            }
        }
    }

    func fight() {
        // Select Targets Phose
        var infectionTargets = immuneSystem
        infection.sorted(by: Group.areInSelectionOrder).forEach { group in
            group.selectTarget(from: &infectionTargets)
        }
        var immuneSystemTargets = infection
        immuneSystem.sorted(by: Group.areInSelectionOrder).forEach { group in
            group.selectTarget(from: &immuneSystemTargets)
        }

        // Attack Phase
        let battleOrder = (infection + immuneSystem).sorted { $0.initiative > $1.initiative }
        battleOrder.forEach { group in
            guard let target = group.target else { return }
            let damage = group.attack(group: target)
            let unitsKilled = target.takeDamage(damage)
//            print("Group killed \(unitsKilled) units of the target")
            group.target = nil
        }
//        print("")

        infection = infection.filter { $0.effectivePower > 0 }
        immuneSystem = immuneSystem.filter { $0.effectivePower > 0 }
    }
}

func partOneSolution() {
    let battle = Battle(with: InputData.challenge, boost: 0)
    repeat {
        battle.fight()
    } while battle.immuneSystem.count > 0 && battle.infection.count > 0

    print("Immune system remaining units:", battle.immuneSystemUnits)
    print("Infection remaining units:", battle.infectionUnits)
}

func partTwoSolution() {
    var solutionFound = false
    var boost = 34
    repeat {
        let battle = Battle(with: InputData.challenge, boost: boost)
        repeat {
            battle.fight()
        } while battle.immuneSystem.count > 0 && battle.infection.count > 0

        print("Immune system remaining units:", battle.immuneSystemUnits)
        print("Infection remaining units:", battle.infectionUnits)

        solutionFound = battle.immuneSystemDidWin
        boost += 1
    } while !solutionFound
    print("\nBoost:", boost)
}

partTwoSolution()
print("Done")
