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

enum MDInterfaceError : Error {
    case InstructionNotSupported
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

final class MDInterface {
    static let shared:MDInterface = MDInterface()
    let mdWorker:DispatchQueue
    let mdOutputLock:DispatchSemaphore
    
    var availableMIDIEndpoints:[MIDIEndpointRef] = [MIDIEndpointRef]()
    var midiClient = MIDIClientRef()
    var midiOutPort = MIDIPortRef()
    var midiEndpoint = MIDIEndpointRef()
    
    var channel: Int
    var pitchBend:UInt8 = 0
    var openNotes: [Note:UInt8] = [Note:UInt8]()
    var outputBuffer:[MIDIPacket] = [MIDIPacket]()
    
    var active: Bool = false
    
    
    private init(){
        MIDIClientCreate("MIDIHero" as CFString, nil, nil, &self.midiClient)
        MIDIOutputPortCreate(self.midiClient, "MIDIHero Output" as CFString, &self.midiOutPort)
        
        self.mdWorker = DispatchQueue(label: "mdinterface.concurrent.queue", attributes: .concurrent)
        self.mdOutputLock = DispatchSemaphore(value: 1)
        
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
        
        self.active = true
        print ("[MIDIHero][MIDI] Connected to: \(getDisplayName(self.midiEndpoint))")
        
        
        self.mdWorker.async(flags: .barrier) { [unowned self] in
            while (self.active){
                // Lock the output buffer, copy it, clear it, then release it.
                self.mdOutputLock.wait()
                let outputBuf = self.outputBuffer
                self.outputBuffer.removeAll()
                self.mdOutputLock.signal()
                
                for inst in outputBuf {
                    var packetList:MIDIPacketList = MIDIPacketList(numPackets: 1, packet: inst);
                    MIDISend(self.midiOutPort, self.midiEndpoint, &packetList)
                }
            }
        }
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
            if let _ = self.openNotes[note] {
                self.openNotes[note]! += 1
            } else {
                self.openNotes[note] = 1
                
                self.mdOutputLock.wait()
                self.outputBuffer.append(createMIDIPacket(msg: midiMessages.NoteOn, action: note.rawValue, value: 100))
                self.mdOutputLock.signal()
            }
        }
    }
    
    func notesOff(notes: [Note]) {
        for note in notes {
            if let count = self.openNotes[note] {
                if (count > 1) {
                    self.openNotes[note]! -= 1
                } else {
                    self.openNotes[note] = nil
                    
                    self.mdOutputLock.wait()
                    self.outputBuffer.append(createMIDIPacket(msg: midiMessages.NoteOff, action: note.rawValue, value: 0))
                    self.mdOutputLock.signal()
                }
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
}
