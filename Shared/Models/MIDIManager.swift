//
//  MIDIManager.swift
//  MIDIHero
//
//  Created by Gordon Swan on 17/09/2022.
//

import Foundation
import CoreMIDI

enum MIDIManagerError : Error {
    case InstructionNotSupported(instruction: String, msg: String)
    case ChannelOutOfRange(value: Int, msg: String)
}

struct MIDIManagerConfig {
    var MIDIEndpointName: String
    var MIDIChannel: Int
}

final class MIDIManager: NSObject, ObservableObject{
    static let shared:MIDIManager = MIDIManager()
    
    let midiWorker:DispatchQueue
    let midiOutputLock:DispatchSemaphore
    
    var midiClient: MIDIClientRef
    var midiOutPort: MIDIPortRef
    var midiEndpoint: MIDIEndpointRef
    
    var midiOutputSource: MIDIEndpointRef
    
    var channel: Int
    var pitchBend: UInt8
    
    override init() {
        self.midiWorker = DispatchQueue(label: "midimanager.concurrent.queue", attributes: .concurrent)
        self.midiOutputLock = DispatchSemaphore(value: 1)
        
        self.midiClient = MIDIClientRef()
        self.midiOutPort = MIDIPortRef()
        self.midiEndpoint = MIDIEndpointRef()
        self.midiOutputSource = MIDIEndpointRef()
        
        self.channel = 1
        self.pitchBend = 0
        
        
        var midiClientError: OSStatus
        print("[MIDI Manager] Creating MIDI Client and Output Port")
        midiClientError = MIDIClientCreate("MIDI Hero" as CFString, nil, nil, &self.midiClient)
        if midiClientError != OSStatus(noErr) {
            print("[MIDI Manager] Failed to create MIDI Client: \(midiClientError)")
        }
        midiClientError = MIDIOutputPortCreate(self.midiClient, "MIDI Hero Output" as CFString, &self.midiOutPort)
        if midiClientError != OSStatus(noErr) {
            print("[MIDI Manager] Failed to create MIDI Output Port: \(midiClientError)")
        }
        midiClientError = MIDISourceCreateWithProtocol(self.midiClient, "MIDI Hero" as CFString, MIDIProtocolID._1_0, &self.midiOutputSource)
        if midiClientError != OSStatus(noErr) {
            print("[MIDI Manager] Failed to create MIDI Output Source: \(midiClientError)")
        }
        
        super.init()
    }
    
    // Return a list of available MIDI Destinations
    public func getMIDIDestinations() -> [(String, MIDIEndpointRef)] {
        let count: Int = MIDIGetNumberOfDestinations();
        var midiEndpoints:[(String,MIDIEndpointRef)] = [(String,MIDIEndpointRef)]()
        
        for i in 0..<count {
            let endpoint:MIDIEndpointRef = MIDIGetDestination(i);
            if (endpoint != 0)
            {
                let endpointName = getDisplayName(endpoint)
                midiEndpoints.append((endpointName, endpoint))
            }
        }
        return midiEndpoints
    }
    
    // Return a list of available MIDI Devices
    public func getMIDIDevices() -> [(String, MIDIEndpointRef)] {
        let count: Int = MIDIGetNumberOfDevices();
        var midiDevices:[(String,MIDIDeviceRef)] = [(String,MIDIDeviceRef)]()
        
        for i in 0..<count {
            let device:MIDIDeviceRef = MIDIGetDestination(i);
            if (device != 0)
            {
                let deviceName = getDisplayName(device)
                midiDevices.append((deviceName, device))
            }
        }
        return midiDevices
    }
    
    // Return the MIDIManager configuration information
    public func getMIDIInfo() -> MIDIManagerConfig {
        return MIDIManagerConfig(
            MIDIEndpointName: getDisplayName(self.midiEndpoint),
            MIDIChannel: self.channel
        )
    }
    // Return the human readable name for a MIDIObjectRef
    private func getDisplayName(_ obj: MIDIObjectRef) -> String {
        var param: Unmanaged<CFString>?
        var name: String = "Error";
        
        let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
        if err == OSStatus(noErr)
        {
            name =  param!.takeRetainedValue() as String
        }
        
        return name;
    }
    
    // Set the MIDI channel
    public func setChannel(channel: Int) throws -> Void {
        if channel < 1 || channel > 16 {
            throw MIDIManagerError.ChannelOutOfRange(value: channel, msg: "Channel out of range [1...16]")
        }
        self.channel = channel
    }
    // Set the MIDI Destination
    public func setMIDIDestination(endpoint: MIDIEndpointRef) throws -> Void {
        // TODO: Implement (does not seem to be required for macOS target)
    }
    // TODO Send MIDI message
    /*
        Use separate thread as a MIDI Worker which reads messages from a dispatch queue and
        sends the messages asynchronously.
        This will decouple the message delivery from the rest of the application, such as
        the controller input parsing.
    */
    
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
    /*
    func notesOn(notes: [Note], value: UInt8) {
        for note in notes {
            if let _ = self.openNotes[note] {
                self.openNotes[note]! += 1
            } else {
                self.openNotes[note] = 1
                
                self.midiOutputLock.wait()
                self.outputBuffer.append(createMIDIPacket(msg: midiMessages.NoteOn, action: note.rawValue, value: 100))
                self.midiOutputLock.signal()
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
                    
                    self.midiOutputLock.wait()
                    self.outputBuffer.append(createMIDIPacket(msg: midiMessages.NoteOff, action: note.rawValue, value: 0))
                    self.midiOutputLock.signal()
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
    */
}

