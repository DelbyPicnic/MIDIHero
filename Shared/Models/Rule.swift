//
//  Rule.swift
//  MIDIHero
//
//  Created by Gordon Swan on 23/01/2021.
//

import Foundation
import CoreMIDI

let controllerFlags:[String: (String, UInt8, UInt8)] = [
    "fret_3":      ("Fret Button 4",   0, 0b00000001),
    "fret_0":      ("Fret Button 1",   0, 0b00000010),
    "fret_1":      ("Fret Button 2",   0, 0b00000100),
    "fret_2":      ("Fret Button 3",   0, 0b00001000),
    "fret_4":      ("Fret Button 5",   0, 0b00010000),
    "fret_5":      ("Fret Button 6",   0, 0b00100000),
    "sys_pause":   ("Pause",           1, 0b00000010),
    "sys_action":  ("Action",          1, 0b00000100),
    "sys_bridge":  ("Bridge",          1, 0b00001000),
    "sys_power":   ("Power",           1, 0b00010000),
    "strum_any":   ("Strumbar",        4, 0b01111111),
    "strum_up":    ("Strumbar Up",     4, 0b00000000),
    "strum_middle":("Strumbar Middle", 4, 0b10000000),
    "strum_down":  ("Strumbar Down",   4, 0b11111111),
    "d_center":    ("Center",          2, 0b00001111),
    "d_up":        ("Up",              2, 0b00000110),
    "d_up_left":   ("Up Left",         2, 0b00000111),
    "d_left":      ("Left",            2, 0b00000000),
    "d_down_left": ("Down Left",       2, 0b00000001),
    "d_down":      ("Down",            2, 0b00000010),
    "d_down_right":("Down Right",      2, 0b00000011),
    "d_right":     ("Right",           2, 0b00000100),
    "d_up_right":  ("Up Right",        2, 0b00000101),
    "vibrato":     ("Vibrato Bar",     6, 0b11110000),
    "gyro":        ("Gyroscope",      19, 0b11111111)
]

enum RuleTypeError: Error {
    case ControllerFlagNotRecognised
    case NoteNotRecognised
    case MIDIMessageNotRecognised
}

enum RuleType {
    case NoteRule
    case ControllerRule
    case ParameterRule
}

enum StrumDirection: UInt8 {
    case StrumUP = 0b00000000
    case StrumDown = 0b11111111
}

protocol Rule {
    var name:String { get set }
    var type:RuleType { get }
    var flag: UInt8 { get }
    var offset:Int { get }
    
    var stateLast:UInt8 { get }
    func process(stateCurrent:[UInt8], stateLast:[UInt8], mdi:MDInterface)
}

class NoteRule: Rule {
    var name: String
    let type: RuleType = RuleType.NoteRule
    var notes: [Note]
    var flag: UInt8
    var offset: Int
    var stateLast: UInt8 = 0
    var strum: StrumDirection
    
    init(name: String, parameter:String, notes:[Note], activator: StrumDirection) throws {
        self.name = name
        self.notes = notes
        // Learn to use enums better so this error handling isn't required.
        guard let eventData:(String, UInt8, UInt8) = controllerFlags[parameter] else {
            throw RuleTypeError.ControllerFlagNotRecognised
        }
        self.offset = Int(eventData.1)
        self.flag = eventData.2
        self.strum = activator
    }
    func process(stateCurrent:[UInt8], stateLast:[UInt8], mdi:MDInterface) {
        // Compare the rule flag against the current state.
        // Compare the current strum state against it's last state
        let newState:UInt8 = stateCurrent[self.offset] & self.flag
        let lastState:UInt8 = stateLast[self.offset] & self.flag
        
        if newState > 0 {
            if (self.strum.rawValue == stateCurrent[4]) {
                if (stateCurrent[4] != stateLast[4]) {
                    mdi.notesOn(notes: self.notes, value: 64)
                }
            }
            
        } else if newState < lastState {
            mdi.notesOff(notes: self.notes)
        }
    }
}
