//
//  DataModels.swift
//  MIDIHero
//
//  Created by Gordon Swan on 22/01/2021.
//

import Foundation

enum Note: UInt8, CaseIterable {
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

// MinMax Midi notes (B0 -> A4)
let MIDINoteRange = (min: 35, max: 81)

let dataMask:UInt8      = 0b01111111
let channelMask:UInt8   = 0b00001111

enum midiMessages: UInt8 {
    case NoteOn        = 0b10010000
    case NoteOff       = 0b10000000
    case PolyPressure  = 0b10100000
    case ControlChange = 0b10110000
    case PitchBend     = 0b11100000
    case SystemCommon  = 0b11110000
}

struct OpenNote {
    private var key:Note
    private var velocity:Int
    init(key:Note, velocity:Int){
        self.key = key
        self.velocity = velocity
    }
    func queryNote(){
        
    }
}
