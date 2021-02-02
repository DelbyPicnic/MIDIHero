//
//  Rule.swift
//  MIDIHero
//
//  Created by Gordon Swan on 23/01/2021.
//

import Foundation
import CoreMIDI

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

enum StrumDirection {
    case StrumUP
    case StrumDown
}

protocol Rule {
    var name:String { get set }
    var type:RuleType { get }
    var channel:UInt8 { get set }
    var flag: UInt8 { get }
    var offset:Int { get }
    
    var stateLast:UInt8 { get }
    
    func process(state:UInt8, mdi:MDInterface)
}

class NoteRule: Rule {
    var name: String
    var channel: UInt8
    var type: RuleType = RuleType.NoteRule
    var flag: UInt8
    var offset: Int
    var strum: StrumDirection
    
    var actionsOn:[MIDIPacket] = [MIDIPacket]()
    var actionsOff:[MIDIPacket] = [MIDIPacket]()

    var stateLast:UInt8 = 0
    
    init(name: String, channel:UInt8, parameter:String, notes:[String], activator:StrumDirection) throws {
        self.name = name
        self.channel = channel & channelMask
        guard let eventData:(String,UInt8,UInt8) = controllerFlags[parameter] else {
            throw RuleTypeError.ControllerFlagNotRecognised
        }
        self.offset = Int(eventData.1)
        self.flag = eventData.2
        self.strum = activator
        
        for note in notes {
            var msgStatusOn:UInt8 = midiMessages.NoteOn.rawValue
            var msgStatusOff:UInt8 = midiMessages.NoteOff.rawValue
            
            msgStatusOn += self.channel
            msgStatusOff += self.channel
            
            let msgNote:UInt8 = UInt8(MIDINotes[note]!) & dataMask
            let msgValue:UInt8 = 0x78
            
            var pktOn = MIDIPacket()
            pktOn.timeStamp = 0
            pktOn.length = 3
            pktOn.data.0 = msgStatusOn
            pktOn.data.1 = msgNote
            pktOn.data.2 = msgValue
            
            var pktOff = MIDIPacket()
            pktOff.timeStamp = 0
            pktOff.length = 3
            pktOff.data.0 = msgStatusOff
            pktOff.data.1 = msgNote
            pktOff.data.2 = 0
            
            self.actionsOn.append(pktOn)
            self.actionsOff.append(pktOff)
        }
    }
    func process(state:UInt8, mdi:MDInterface) {
        let newState:UInt8 = state & self.flag
        if newState > 0 {
            self.stateLast = newState
            switch self.strum {
            case .StrumUP:
                mdi.AddUpperNotes(packets: self.actionsOn)
            case .StrumDown:
                mdi.AddLowerNotes(packets: self.actionsOn)
            }
        } else if newState < stateLast  {
            // add midi packets to midi interface
            mdi.AddPackets(packets: self.actionsOff)
            self.stateLast = newState
        }
    }
}

class ControllerRule: Rule {
    var name: String
    var channel: UInt8
    var type: RuleType = RuleType.ControllerRule
    var flag: UInt8
    var offset: Int
    var actionsOn:[MIDIPacket] = [MIDIPacket]()
    
    var stateLast:UInt8 = 0
    
    init(name: String, channel:UInt8, parameter:String, controlChanges:[UInt8], value:UInt8) throws {
        self.name = name
        self.channel = channel & channelMask
        guard let eventData:(String,UInt8,UInt8) = controllerFlags[parameter] else {
            throw RuleTypeError.ControllerFlagNotRecognised
        }
        self.offset = Int(eventData.1)
        self.flag = eventData.2
        
        for cc in controlChanges {
            var msgStatusOn:UInt8 = midiMessages.ControlChange.rawValue
            msgStatusOn += self.channel
            
            let msgAction:UInt8 = cc & dataMask
            let msgValue:UInt8 = value & dataMask
            
            var packet:MIDIPacket = MIDIPacket()
            packet.timeStamp = 0
            packet.data.0 = msgStatusOn
            packet.data.1 = msgAction
            packet.data.2 = msgValue
            
            self.actionsOn.append(packet)
        }
    }
    func process(state:UInt8, mdi:MDInterface) {
        let newState:UInt8 = state & self.flag
        if newState > stateLast {
            mdi.AddPackets(packets:self.actionsOn)
        }
    }
}
