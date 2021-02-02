//
//  DataModels.swift
//  MIDIHero
//
//  Created by Gordon Swan on 22/01/2021.
//

import Foundation

let dataMask:UInt8      = 0b01111111
let channelMask:UInt8   = 0b00001111

enum Note: Int {
    case B0 = 35
    case C1 = 36
    case Db1 = 37
    case D1 = 38
    case Eb1 = 39
    case E1 = 40
    case F1 = 41
    case Gb1 = 42
    case G1 = 43
    case Ab1 = 44
    case A1 = 45
    case Bb1 = 46
    case B1 = 47
    case C2 = 48
    case Db2 = 49
    case D2 = 50
    case Eb2 = 51
    case E2 = 52
    case F2 = 53
    case Gb2 = 54
    case G2 = 55
    case Ab2 = 56
    case A2 = 57
    case Bb2 = 58
    case B2 = 59
    case C3 = 60
    case Db3 = 61
    case D3 = 62
    case Eb3 = 63
    case E3 = 64
    case F3 = 65
    case Gb3 = 66
    case G3 = 67
    case Ab3 = 68
    case A3 = 69
    case Bb3 = 70
    case B3 = 71
    case C4 = 72
    case Db4 = 73
    case D4 = 74
    case Eb4 = 75
    case E4 = 76
    case F4 = 77
    case Gb4 = 78
    case G4 = 79
    case Ab4 = 80
    case A4 = 81
}

enum midiMessages: UInt8 {
    case NoteOn        = 0b10010000
    case NoteOff       = 0b10000000
    case PolyPressure  = 0b10100000
    case ControlChange = 0b10110000
    case PitchBend     = 0b11100000
    case SystemCommon  = 0b11110000
}

let MIDINotes:[String:UInt8] = [
    "B0" : 35,
    "C1" : 36,
    "C#1" : 37,
    "D1" : 38,
    "Eb1" : 39,
    "E1" : 40,
    "F1" : 41,
    "F#1" : 42,
    "G1" : 43,
    "Ab1" : 44,
    "A1" : 45,
    "Bb1" : 46,
    "B1" : 47,
    "C2" : 48,
    "C#2" : 49,
    "D2" : 50,
    "Eb2" : 51,
    "E2" : 52,
    "F2" : 53,
    "F#2" : 54,
    "G2" : 55,
    "Ab2" : 56,
    "A2" : 57,
    "Bb2" : 58,
    "B2" : 59,
    "C3" : 60,
    "C#3" : 61,
    "D3" : 62,
    "Eb3" : 63,
    "E3" : 64,
    "F3" : 65,
    "F#3" : 66,
    "G3" : 67,
    "Ab3" : 68,
    "A3" : 69,
    "Bb3" : 70,
    "B3" : 71,
    "C4" : 72,
    "C#4" : 73,
    "D4" : 74,
    "Eb4" : 75,
    "E4" : 76,
    "F4" : 77,
    "F#4" : 78,
    "G4" : 79,
    "Ab4" : 80,
    "A4" : 81
]

/*
let midiMessages:[String:UInt8] = [
    "Note On"       : 0b10010000,
    "Note Off"      : 0b10000000,
    "Poly Pressure" : 0b10100000,
    "Control Change": 0b10110000,
    "Pitch Bend"    : 0b11100000,
    "System Common" : 0b11110000
]
*/
 
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
