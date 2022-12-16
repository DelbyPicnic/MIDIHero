//
//  EventHandler.swift
//  MIDIHero
//
//  Created by Gordon Swan on 22/09/2022.
//

import Foundation

struct Event {
    let type: MIDIEventType
    let address: UInt8
    let value: UInt8?
}


final class EventHandler {
    static let shared: EventHandler = EventHandler()
    private let midiManager:MIDIManager
    
    
    private init() {
        self.midiManager = MIDIManager.shared
    }
    
    private func handleMIDINoteOn(event: Event) -> Void {
        self.midiManager.createMIDIPacketWord1_0(
            message: MIDIManager.MIDIMessage1_0.NoteOn,
            data0: event.address,
            data1: event.value!
        )
    }
    private func handleMIDINoteOff(event: Event) -> Void {
        self.midiManager.createMIDIPacketWord1_0(
            message: MIDIManager.MIDIMessage1_0.NoteOff,
            data0: event.address
        )
    }
    private func handleMIDICC(event: Event) -> Void {
        self.midiManager.createMIDIPacketWord1_0(
            message: MIDIManager.MIDIMessage1_0.ControlChange,
            data0: event.address,
            data1: event.value!
        )
    }
    private func handleMIDIPitchBend(event: Event) -> Void {
        self.midiManager.createMIDIPacketWord1_0(
            message: MIDIManager.MIDIMessage1_0.PitchBend,
            data0: event.address,
            data1: event.value!
        )
    }
    private func NOOP(event: Event) -> Void {
        print("[Event Handler]: \(event.type) not yet implemented")
    }
    
    public func handleEvents(events: [Event]) -> Void {
        for event in events {
            switch event.type {
            case .MIDINoteOn:
                self.handleMIDINoteOn(event: event)
            case .MIDINoteOff:
                self.handleMIDINoteOff(event: event)
            case .MIDIControlChange:
                self.handleMIDICC(event: event)
            case .MIDIPitchBend:
                self.handleMIDIPitchBend(event: event)
            default:
                self.NOOP(event: event)
            }
        }
        self.midiManager.flush()
    }
}
