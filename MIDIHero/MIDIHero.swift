//
//  MIDIHero.swift
//  MIDIHero
//
//  Created by Gordon Swan on 02/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import Foundation

// Application Modes
enum appMode: String {
    case GATE = "Gate Mode"
    case STRING = "Strings Mode"
}

// Strum bar input representation
enum strumBar: Int {
    // Raw values are integer representations of the raw byte value from the guitar
    case UP = 255
    case DOWN = 0
    case NULL = 128
}

// Directional input representation
enum directionButtons: Int {
    // Raw values are integer representations of the raw byte value from the guitar
    case UP_RIGHT = 7
    case RIGHT = 6
    case DOWN_RIGHT = 5
    case DOWN = 4
    case DOWN_LEFT = 3
    case LEFT = 2
    case UP_LEFT = 1
    case UP = 0
    case NULL = 15
}

enum MIDIHeroError: Error {
    case noteOutOfRange
    case noteNotFound(note: String)
    case buttonOutOfRange
    case valueOutOfRange
    case sysButtonNotFound(button: String)
    case directionButtonNotFound(button: String)
    case sensorNotFound(sensor: String)
}

class MIDIHero {
    // MIDI Note Conversion and Processing
    let MIDINoteRange = (min: 35, max: 81)    // MinMax Midi notes (B0 -> A4)
    let MIDINotes = [(35, "B0"), (36, "C1"), (37, "C#1"),(38, "D1"),
                      (39, "Eb1"),(40, "E1"), (41, "F1"), (42, "F#1"),
                      (43, "G1"), (44, "Ab1"),(45, "A1"), (46, "Bb1"),
                      (47, "B1"), (48, "C2"), (49, "C#2"),(50, "D2"),
                      (51, "Eb2"),(52, "E2"), (53, "F2"), (54, "F#2"),
                      (55, "G2"), (56, "Ab2"),(57, "A2"), (58, "Bb2"),
                      (59, "B2"), (60, "C3"), (61, "C#3"),(62, "D3"),
                      (63, "Eb3"),(64, "E3"), (65, "F3"), (66, "F#3"),
                      (67, "G3"), (68, "Ab3"),(69, "A3"), (70, "Bb3"),
                      (71, "B3"), (72, "C4"), (73, "C#4"),(74, "D4"),
                      (75, "Eb4"),(76, "E4"), (77, "F4"), (78, "F#4"),
                      (79, "G4"), (80, "Ab4"),(81, "A4")]
    
    // Instrument Variables
    // FRETS: 1 2 3 4 5 6
    var fretBtnNotes:[Int] = [57, 58, 59, 60, 61, 62]
    // SYS: PAUSE ACTION BRIDGE POWER
    var sysBtnValues:[(String,Int)] = [("Pause", 0),("Action",1),("Bridge",2),("Power",3)]
    // DRIECTIONS: UP UP_LEFT LEFT DOWN_LEFT DOWN DOWN_RIGHT RIGHT UP_RIGHT
    var directBtnValues:[(String,Int)] = [("Up",102), ("Up Left",103),
                                          ("Left",104), ("Down Left",105),
                                          ("Down",106), ("Down Right",107),
                                          ("Right",108), ("Up Right",109)]
    // STRUMBAR
    var stringDelineation:Bool = false
    // VIBRATO BAR & GYRO
    var rangedSensors:[(String,Int)] = [("Vibrato Bar", 4),("Orientation", 5)]
    
    
    // Find the MIDI note doe a given integer value
    func numToNote(nNumber:Int) throws ->String{
        if (nNumber >= self.MIDINoteRange.min && nNumber <= self.MIDINoteRange.max){
            for nPair in MIDINotes{
                if (nPair.0 == nNumber){
                    return nPair.1
                }
            }
        }
        throw MIDIHeroError.noteOutOfRange
    }
    
    // Find the integer value for a MIDI note
    func noteToNum(nName: String) throws ->Int{
        for nPair in self.MIDINotes{
            if (nPair.1 == nName){
                return nPair.0
            }
        }
        throw MIDIHeroError.noteNotFound(note: nName)
    }
    
    // Return all of the available note names as a list of strings
    func allNotes()->[String]{
        var notes:[String] = []
        for nPair in MIDINotes{
            notes.append(nPair.1)
        }
        return notes
    }
    
    func noteAtIntegral(intPos: Int) throws ->String{
        if(intPos >= 0 && intPos < MIDINotes.count){
            return MIDINotes[intPos].1
        }else{
            throw MIDIHeroError.valueOutOfRange
        }
    }
    
    // Get max note value
    func getMax()->Int{
        return self.MIDINoteRange.max
    }
    // Get min note value
    func getMin()->Int{
        return self.MIDINoteRange.min
    }
    // Get the total number of declarable MIDI notes
    func countNotes()->Int{
        return self.MIDINotes.count
    }

    // Sets a MIDI note for a specific button
    func setFretBtnNote(btn: Int, note: Int) throws {
        if(btn >= 0 && btn <= 5){
            if(note >= self.MIDINoteRange.min && note <= self.MIDINoteRange.max){
                self.fretBtnNotes[btn] = note
            }else{
                throw MIDIHeroError.noteOutOfRange
            }
        }else{
            throw MIDIHeroError.buttonOutOfRange
        }
    }
    
    // Find the currently set integer value for a specidied fret button
    func getFretBtnNote(btn: Int) throws -> Int{
        if(btn >= 0 && btn <= 5){
            return self.fretBtnNotes[btn]
        }else{
            throw MIDIHeroError.buttonOutOfRange
        }
    }
    
    // Find the currently set note name for a specidied fret button
    func getFretBtnNote(btn: Int) throws -> String{
        if(btn >= 0 && btn <= 5){
            return try self.numToNote(nNumber: self.fretBtnNotes[btn])
        }else{
            throw MIDIHeroError.buttonOutOfRange
        }
    }
    
    // Get currently set integer value for specified system button
    func getSysBtnValue(btn: String) throws -> Int{
        for sysBtn in self.sysBtnValues{
            if (sysBtn.0 == btn){
                return sysBtn.1
            }
        }
        throw MIDIHeroError.sysButtonNotFound(button: btn)
    }
    // Same as above, using integer to select button instead
    func getSysBtnValue(btn: Int) throws -> Int{
        if(btn >= 0 && btn <= sysBtnValues.count){
            return sysBtnValues[btn].1
        }else{
            throw MIDIHeroError.valueOutOfRange
        }
    }
    
    // Set integer value for specified system button
    func setSysBtnValue(btn: String, value: Int) throws{
        if(value >= 0 && value <= 120){
            var targetSet = false
            for (index, sysBtn) in self.sysBtnValues.enumerated(){
                if (btn == sysBtn.0){
                    self.sysBtnValues[index].1 = value
                    targetSet = true
                }
            }
            if(!targetSet){
                throw MIDIHeroError.sysButtonNotFound(button: btn)
            }
        }else{
            throw MIDIHeroError.valueOutOfRange
        }
    }
    
    // Get currently set integer value for specified direction button
    func getDirectBtnValue(btn: String) throws -> Int{
        for directBtn in self.directBtnValues{
            if (directBtn.0 == btn){
                return directBtn.1
            }
        }
        throw MIDIHeroError.directionButtonNotFound(button: btn)
    }
    
    // Set integer value for specified directional button
    func setDirectBtnValue(btn: String, value: Int) throws{
        if(value >= 0 && value <= 120){
            var targetSet = false
            for (index, directBtn) in self.sysBtnValues.enumerated(){
                if (btn == directBtn.0){
                    self.directBtnValues[index].1 = value
                    targetSet = true
                }
            }
            if(!targetSet){
                throw MIDIHeroError.directionButtonNotFound(button: btn)
            }
        }else{
            throw MIDIHeroError.valueOutOfRange
        }
    }
    
    // Get string delineation setting
    func getStringDelineation()->Bool{
        return self.stringDelineation
    }
    // Set string delineation setting
    func setStringDelineation(stat: Bool){
        self.stringDelineation = stat
    }
    
    // Get ranged sensors numbers
    func getRangedSensor(sen: String) throws -> Int{
        for sensor in rangedSensors {
            if(sen == sensor.0){
                return sensor.1
            }
        }
        throw MIDIHeroError.sensorNotFound(sensor: sen)
    }
    
    // Set ranged sensors
    func setRangedSensor(sen: String, val: Int) throws{
        if(val >= 0 && val <= 120){
            var targetSet = false
            for (index,sensor) in rangedSensors.enumerated(){
                if(sen == sensor.0){
                    rangedSensors[index].1 = val
                    targetSet = true
                }
            }
            if(!targetSet){
                throw MIDIHeroError.sensorNotFound(sensor: sen)
            }
        }else{
            throw MIDIHeroError.valueOutOfRange
        }
    }
    
}
