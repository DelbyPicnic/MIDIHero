//
//  MDInterface.swift
//  MIDIHero
//
//  Created by Gordon Swan on 18/01/2021.
//

import Foundation
import CoreMIDI

enum MDInterfaceError : Error {
    case InstructionNotSupported
}

final class MDInterface {
    static let shared:MDInterface = MDInterface()
    
    var availableMIDIEndpoints:[MIDIEndpointRef] = [MIDIEndpointRef]()
    var midiClient = MIDIClientRef()
    var midiOutPort = MIDIPortRef()
    var midiEndpoint = MIDIEndpointRef()
    
    var midiChannel: Int
    var pitchBend:UInt8 = 0
    
    var msgCounter:[UInt8:UInt16] = [UInt8:UInt16]()
    
    var outputBuffer:[MIDIPacket] = [MIDIPacket]()
    var upperNoteBuffer:[MIDIPacket] = [MIDIPacket]() // send on strum up
    var lowerNoteBuffer:[MIDIPacket] = [MIDIPacket]() // send on strum down
    var retrigBuffer:[MIDIPacket] = [MIDIPacket]()    // retrigger buffer
    
    private init(){
        MIDIClientCreate("MIDIHero" as CFString, nil, nil, &self.midiClient)
        MIDIOutputPortCreate(self.midiClient, "MIDIHero Output" as CFString, &self.midiOutPort)
        
        self.midiEndpoint = MIDIGetDestination(1)
        self.midiChannel = 0
        
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
    
    func AddPackets(packets: [MIDIPacket]) {
        for pkt in packets {
            self.outputBuffer.append( pkt )
        }
    }
    func AddUpperNotes(packets: [MIDIPacket]) {
        for pkt in packets {
            self.upperNoteBuffer.append( pkt )
        }
    }
    func AddLowerNotes(packets: [MIDIPacket]) {
        for pkt in packets {
            self.lowerNoteBuffer.append( pkt )
        }
    }
    func strum(direct: StrumDirection) {
        print ("Output Buffer: \(self.outputBuffer.count) values")
        switch direct {
        case .StrumUP:
            self.outputBuffer += upperNoteBuffer
            
        case .StrumDown:
            self.outputBuffer += lowerNoteBuffer
        }
    }
    func flush(){
        // create midi packet list from packets
        for pkt in self.outputBuffer {
            
            let stat = String(pkt.data.0, radix: 2)
            let param = String(pkt.data.1, radix: 2)
            let value = String(pkt.data.2, radix: 2)
            
            print ("Packet: \(stat) \(param) \(value)")
            var pktList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: pkt)
            MIDISend(self.midiOutPort, self.midiEndpoint, &pktList)
        }
        self.outputBuffer.removeAll()
        self.upperNoteBuffer.removeAll()
        self.lowerNoteBuffer.removeAll()
    }
}
