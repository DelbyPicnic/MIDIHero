//
//  Ruleset.swift
//  MIDIHero
//
//  Created by Gordon Swan on 20/09/2022.
//

import Foundation

/*
    PLAN/NOTES:
    This file should be responsible for representing and transforming controller events into midi instructions.
*/

enum RuleType: Codable {
    case Composite  // note rule    - requires two triggers (fret + strumbar) -> note_on. creates two conditions
    case Momentary  // one-shot     - has a trigger and an instruction (action) -> sys_1. creates one condition
}

struct ControllerStateCondition: Codable {
    var inputType: InputType
    var inputState: InputState
}

struct Rule: Identifiable, Codable {
    var id: UUID = UUID()
    var type: RuleType
    var hold: Bool
    
    var controllerEvents: [ControllerStateCondition]
}

struct Condition {
    var parent_id: UUID
    var events: [ControllerEvent]
    var actions: [Event]
}

final class Ruleset {
    static let shared:Ruleset = Ruleset()
    
    private var rules: [Rule]
    private var conditions: [Condition]
    
    
    private init (){
        self.rules = [Rule]()
        self.conditions = [Condition]()
        
    }
    
    // create a new rule
    public func createRule() throws -> Void {
        // create a rule instance
        // create the required conditions for the rule
    }
    
    // modify an existing rule
    public func updateRule() throws -> Void {
        // get the rule from the list or throw error if not exist
        // delete corresponding rule conditions
        // create new conditions from the new rule config
        // update the rule and add back to list
    }
    
    // delete an existing rule
    public func deleteRule() throws -> Void {
        // get the rule from the list or throw error if not exist
        // delete corresponding rule conditions
        // delete the rule and list reference
    }
    
    // get a specific rule
    public func getRule() -> Rule {
        // find rule with UUID
        // return rule if exists else error
        
        return self.rules[0]
    }
    
    // get all rules
    public func getRules() -> [Rule] {
        // return all rules
        return self.rules
    }
    
    // load rules from a JSON file
    public func loadFromFile(path: String) throws -> Void{
        // open JSON file from path
        // try to parse file into rules, generating conditions for each
    }
    
    public func transformControllerEvents(events: [ControllerEvent]) -> [Event] {
        var appEvents: [Event] = [Event]()
        for condition in self.conditions {
            if self.testCondition(cond: condition, events: events) {
                appEvents.append(contentsOf: condition.actions)
            }
        }
        return appEvents
    }
    
    // test condition against controller events list
    private func testCondition(cond: Condition, events: [ControllerEvent]) -> Bool {
        for cEvent in cond.events {
            if !events.contains(
                where: {$0.Name == cEvent.Name && $0.State == cEvent.State}
            ) {
               return false
            }
        }
        return true
    }
}
