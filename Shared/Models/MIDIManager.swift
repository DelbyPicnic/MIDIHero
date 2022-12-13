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
    case ChannelOutOfRange(value: UInt8, msg: String)
    case CouldntCreateEventPacket(msg: String)
}

enum MIDIEventType {
    case MIDINoteOn
    case MIDINoteOff
    case MIDIControlChange
    case MIDIPolyPressure
    case MIDIPitchBend
    case SystemCommon
    // Potential for application-related events like 'change-patch' or 'panic'
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
    var midiOutputSource: MIDIEndpointRef
    
    var group: UInt8
    var channel: UInt8
    
    var midiPackets: [UInt32]
    
    enum MIDIMessage1_0: UInt8 {
        case NoteOn        = 0b10010000
        case NoteOff       = 0b10000000
        case PolyPressure  = 0b10100000
        case ControlChange = 0b10110000
        case PitchBend     = 0b11100000
        case SystemCommon  = 0b11110000
    }
    
    private override init() {
        self.midiWorker = DispatchQueue(label: "midimanager.concurrent.queue", attributes: .concurrent)
        self.midiOutputLock = DispatchSemaphore(value: 1)
        
        self.midiClient = MIDIClientRef()
        self.midiOutPort = MIDIPortRef()
        self.midiOutputSource = MIDIEndpointRef()
        
        self.group = 1
        self.channel = 1
        
        self.midiPackets = [UInt32]()
        
        // Create CoreMIDI Client and virtual Output Peripheral
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
            MIDIEndpointName: getDisplayName(self.midiOutputSource),
            MIDIChannel: Int(self.channel)
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
    public func setChannel(channel: UInt8) throws -> Void {
        if channel < 1 || channel > 16 {
            throw MIDIManagerError.ChannelOutOfRange(value: channel, msg: "Channel out of range [1...16]")
        }
        self.channel = channel
    }
    
    // Create MIDI 1.0 Packet as Universal MIDI Packet and add to buffer
    public func createMIDIPacketWord1_0(message: MIDIMessage1_0, data0: UInt8, data1: UInt8 = 0b00000000) -> Void {
        let mtg: UInt8 = (0x2 << 4 | (self.group & 0xF))
        let stat:UInt8 = (message.rawValue | (self.channel & 0xF))
        let d0: UInt8 = (data0 & 0x7F)
        let d1: UInt8 = (data1 & 0x7F)
        
        self.midiPackets.append(UInt32(UInt32(mtg) << 24 | UInt32(stat) << 16 | UInt32(d0) << 8 | UInt32(d1)))
    }
    
    public func flush() -> Void {
        if self.midiPackets.count < 1 {
            print("[MIDI Manager] No MIDI messages to send in flush")
            return
        }
        do {
            let midiEventPacket = try createMIDIEventPacket(
                words: self.midiPackets
            )
            self.sendMIDIEventPacket(eventPacket: midiEventPacket)
            
            self.midiPackets = [UInt32]()
            return
            
        } catch (MIDIManagerError.CouldntCreateEventPacket(let msg)) {
            print("[MIDI Manager]: Failed to send MIDI Event Packet: \(msg)")
        } catch {
            print("[MIDI Manager]: Failed to send MIDI Event Packet: An unknown error ocured.")
        }
    }
    
    // This code is mad, i'm still not entirely sure why swift mandates this.
    private func createMIDIEventPacket(words: [UInt32]) throws -> MIDIEventPacket {
        let midiEventPacketBuilder = MIDIEventPacket.Builder(maximumNumberMIDIWords: words.count)
        midiEventPacketBuilder.timeStamp = 0
        
        for word in words {
            midiEventPacketBuilder.append(word)
        }
        let eventPacket = midiEventPacketBuilder.withUnsafePointer {
            (evt: UnsafePointer<MIDIEventPacket>) -> Result<MIDIEventPacket, Error> in
            let eventPacket = evt.pointee
            let res: Result<MIDIEventPacket, Error> = .success(eventPacket)
            return res
        }
        switch eventPacket {
        case .success(let evtPacket):
            return evtPacket
        default:
            throw MIDIManagerError.CouldntCreateEventPacket(msg: "Failed to create MIDIEventPacket")
        }
    }
    
    // Send MIDIEventPacket to output source
    private func sendMIDIEventPacket(eventPacket: MIDIEventPacket) -> Void {
        var midiEventList: MIDIEventList = MIDIEventList(
            protocol: MIDIProtocolID._1_0,
            numPackets: 1,
            packet: eventPacket
        )
        MIDISendEventList(self.midiOutPort, self.midiOutputSource, &midiEventList)
    }
}

