//
//  MIDIInterface.swift
//  MIDIHero
//
//  Created by Gordon Swan on 01/02/2021.
//

import Foundation
import CoreMIDI

enum MIDIInterfaceMode {
    case Sustain
    case Tight
}

enum MIDIInterfaceError : Error {
    case InstructionNotSupported
}

final class MIDIInterface {
    static let shared:MIDIInterface = MIDIInterface()
    
    var availableMIDIEndpoints:[MIDIEndpointRef] = [MIDIEndpointRef]()
    var midiClient = MIDIClientRef()
    var midiOutPort = MIDIPortRef()
    var midiEndpoint = MIDIEndpointRef()
    
    var channel: Int
    var pitchBend:UInt8 = 0
    var sustain: Int = 1
    var openNotes: [Note:Int] = [Note:Int]()
    var outputBuffer:[MIDIPacket] = [MIDIPacket]()
    
    var active: Bool = false
    
    
    private init(){
        MIDIClientCreate("MIDIHero" as CFString, nil, nil, &self.midiClient)
        MIDIOutputPortCreate(self.midiClient, "MIDIHero Output" as CFString, &self.midiOutPort)
        
        self.midiEndpoint = MIDIGetDestination(1)
        self.channel = 0
        
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
    
    func notesOn(notes: [Note], value: Int) {
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
    }
    
    func pitch(value: UInt8) {
        // create pitch bend midi packet
        // add pitch bend packet to output buffer
    }
    
    func update(){
        // send all messages in output buffer
        // update note values
    }
}
