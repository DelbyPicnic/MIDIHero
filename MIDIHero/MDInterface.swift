//
//  MIDIInterface.swift
//  MIDIHero
//
//  Created by Gordon Swan on 01/02/2021.
//

import Foundation
import CoreMIDI

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

enum MDInterfaceMode {
    case Sustain
    case Tight
}

enum MDInterfaceError : Error {
    case InstructionNotSupported
}

final class MDInterface {
    static let shared:MDInterface = MDInterface()
    
    var availableMIDIEndpoints:[MIDIEndpointRef] = [MIDIEndpointRef]()
    var midiClient = MIDIClientRef()
    var midiOutPort = MIDIPortRef()
    var midiEndpoint = MIDIEndpointRef()
    
    var channel: Int
    var pitchBend:UInt8 = 0
    var sustain: UInt8 = 1
    var openNotes: [Note:UInt8] = [Note:UInt8]()
    var outputBuffer:[MIDIPacket] = [MIDIPacket]()
    
    var active: Bool = false
    
    
    private init(){
        MIDIClientCreate("MIDIHero" as CFString, nil, nil, &self.midiClient)
        MIDIOutputPortCreate(self.midiClient, "MIDIHero Output" as CFString, &self.midiOutPort)
        
        self.midiEndpoint = MIDIGetDestination(1)
        self.channel = 2
        
        print("[MIDIHero][MIDI] Available Connections: \(MIDIGetNumberOfDestinations())")
        // Get all MIDI destinations and add them to array
        let count: Int = MIDIGetNumberOfDestinations();
        for i in 0..<count {
            let endpoint:MIDIEndpointRef = MIDIGetDestination(i);
            if (endpoint != 0)
            {
                self.availableMIDIEndpoints.append(endpoint)
                print("\t \(getDisplayName(endpoint))")
            }
        }

        print ("[MIDIHero][MIDI] Connected to: \(getDisplayName(self.midiEndpoint))")
    }
    
    func getDisplayName(_ obj: MIDIObjectRef) -> String{
        var param: Unmanaged<CFString>?
        var name: String = "Error";
        
        let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
        if err == OSStatus(noErr)
        {
            name =  param!.takeRetainedValue() as String
        }
        
        return name;
    }
    
    func createMIDIPacket(msg: midiMessages, action: UInt8, value:UInt8) -> MIDIPacket {
        var msgStatus:UInt8 = msg.rawValue
        msgStatus += UInt8(self.channel)
        
        let msgAction:UInt8 = action & dataMask
        let msgValue:UInt8 = value & dataMask
        
        var packet:MIDIPacket = MIDIPacket()
        packet.length = 3
        packet.timeStamp = 0
        packet.data.0 = msgStatus
        packet.data.1 = msgAction
        packet.data.2 = msgValue
        
        return packet
    }
    
    func notesOn(notes: [Note], value: UInt8) {
        for note in notes {
            self.openNotes[note] = value
        }
    }
    
    func notesOff(notes: [Note]) {
        for note in notes {
            if let _ = self.openNotes[note] {
                self.openNotes[note] = 0
            }
        }
    }
    
    func controller(param: UInt8, value: UInt8) {
        // create controller change midi packet
        // add controller change packet to output buffer
        self.outputBuffer.append(createMIDIPacket(msg: midiMessages.ControlChange, action: param, value: value))
    }
    
    func pitch(value: UInt8) {
        // create pitch bend midi packet
        // add pitch bend packet to output buffer
        self.outputBuffer.append(createMIDIPacket(msg: midiMessages.PitchBend, action: 0, value: value))
    }
    
    func flush(){
        // send all messages in output buffer
        // update note values
        for (note, velocity) in self.openNotes {
            if (velocity > 0) {
                if (velocity < self.sustain) {
                    self.openNotes[note]! = 0
                    
                    self.outputBuffer.append(createMIDIPacket(msg: midiMessages.NoteOff, action: note.rawValue, value: 0))
                } else {
                    let value = velocity - self.sustain
                    self.openNotes[note]! = value
                    
                    self.outputBuffer.append(createMIDIPacket(msg: midiMessages.NoteOn, action: note.rawValue, value: value))
                }
            } else {
                
            }
        }
        // Learn to use MIDIPacketList properly to optimise this section
        // Double `for` loop is shite code man
        for pkt in self.outputBuffer {
            /*
            let stat = String(pkt.data.0, radix: 2)
            let param = String(pkt.data.1, radix: 2)
            let value = String(pkt.data.2, radix: 2)
            
            print ("Packet: \(stat) \(param) \(value)")
            */
            
            var pktList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: pkt)
            MIDISend(self.midiOutPort, self.midiEndpoint, &pktList)
        }
        self.outputBuffer.removeAll()
    }
}
