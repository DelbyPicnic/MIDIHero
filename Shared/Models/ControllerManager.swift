//
//  ControllerManager.swift
//  MIDIHero
//
//  Created by Gordon Swan on 17/09/2022.
//

import Foundation

enum ControllerError: Error {
    case UnknownControllerEvent
}

final class ControllerManager: NSObject, ObservableObject {
    
    private var ControllerState: ControllerStateTransformer
    
    private var controllerBuffer: [UInt8] = Array(repeating: 0b00000000, count: 20)
    
    public func DidChangeState(buffer: [UInt8]) -> Void {
        self.ControllerState.updateState(buff: buffer)
        
        let events = self.ControllerState.getEvents()
        if events.count != 0 {
            for event in events {
                print("\(event.Name): \t\(event.State)\t\t \(ByteToString(byte: event.debugByte, toSize: 8))")
            }
        }
        
    }
    
    override init(){
        self.ControllerState = ControllerStateTransformer()
        super.init()
    }
}

private class ControllerStateTransformer {
    private var controllerBuffer: [UInt8]
    private var eventList: [ControllerEvent]
    
    // Controller State Change Event
    struct ControllerEvent {
        var Name: InputType
        var State: InputState
        var Value: Any?
        var debugByte: UInt8
    }
    
    // Controller Input States
    enum InputState {
        case Changed
        case StrumUp
        case StrumDown
        case Pressed
        case Depressed
        case Up
        case Down
        case Left
        case Right
        case UpLeft
        case UpRight
        case DownLeft
        case DownRight
        case None
    }
    // Controller Input Types
    enum InputType {
        case Fret1, Fret2, Fret3, Fret4, Fret5, Fret6
        case Strumbar
        case Pause
        case Action
        case Bridge
        case Power
        case Gyro
        case Vibrato
        case Directional
    }
    
    // Controller Input Offsets
    enum Offsets: Int, CaseIterable {
        case FRET = 0
        case SYS = 1
        case DRIRECTIONAL = 2
        case STRUM = 4
        case VIBRATO = 6
        case BATTERY = 18
        case GYRO = 19
    }
    // FRETS: 1 2 3 4 5 6
    private let fretFlags: [(InputType,UInt8)] = [
        (InputType.Fret4, 0b00000001),
        (InputType.Fret1, 0b00000010),
        (InputType.Fret2, 0b00000100),
        (InputType.Fret3, 0b00001000),
        (InputType.Fret5, 0b00010000),
        (InputType.Fret6, 0b00100000)
    ]
    // SYS: PAUSE ACTION BRIDGE POWER
    private let sysFlags: [(InputType, UInt8)] = [
        (InputType.Pause,   0b00000010),
        (InputType.Action,  0b00000100),
        (InputType.Bridge,  0b00001000),
        (InputType.Power,   0b00010000)
    ]
    // STRUMBAR
    private let strumBarFlags: [(InputState,UInt8)] = [
        (InputState.StrumUp,    0b00000000),
        (InputState.StrumDown,  0b11111111),
        (InputState.None,       0b10000000)
    ]
    // DRIECTIONS: UP UP_LEFT LEFT DOWN_LEFT DOWN DOWN_RIGHT RIGHT UP_RIGHT
    private let directionalFlags: [(InputState, UInt8)] = [
        (InputState.Up,         0b0110),
        (InputState.UpLeft,     0b0111),
        (InputState.Left,       0b0000),
        (InputState.DownLeft,   0b0001),
        (InputState.Down,       0b0010),
        (InputState.DownRight,  0b0011),
        (InputState.Right,      0b0100),
        (InputState.UpRight,    0b0101),
        (InputState.None,       0b1111)
    ]

    init () {
        self.controllerBuffer = Array(repeating: 0b00000000, count: 20)
        self.eventList = [ControllerEvent]()
        
        // Certain controller states are non-zero - update initial buffer
        self.controllerBuffer[2] = 0b00001111   // Directional Pad
        self.controllerBuffer[4] = 0b10000000   // Strumbar
    }
    
    public func updateState(buff: [uint8]) -> Void {
        // build events list here
        var events:[ControllerEvent] = [ControllerEvent]()
        
        for offset in Offsets.allCases {
            switch offset {
            case .FRET:
                for fretFlag in fretFlags {
                    // check if the flag is set and if it has changed since last evaluated
                    let (btnState, btnChanged) = bitwiseStateChange(current: buff[offset.rawValue], last: self.controllerBuffer[offset.rawValue], flag: fretFlag.1)
                    // if the button state has changed since last evaluation, create event
                    if btnChanged {
                        let fretState = (btnState) ? InputState.Pressed : InputState.Depressed
                        events.append(ControllerEvent(Name: fretFlag.0, State: fretState, Value: nil, debugByte: buff[offset.rawValue]))
                    }
                }
            
            case .SYS:
                for sysFlag in sysFlags {
                    // check if the flag is set and if it has changed since last evaluated
                    let (btnState, btnChanged) = bitwiseStateChange(current: buff[offset.rawValue], last: self.controllerBuffer[offset.rawValue], flag: sysFlag.1)
                    // if the button state has changed since last evaluation, create event
                    if btnChanged {
                        let buttonState = (btnState) ? InputState.Pressed : InputState.Depressed
                        events.append(ControllerEvent(Name: sysFlag.0, State: buttonState, Value: nil, debugByte: buff[offset.rawValue]))
                    }
                }
            case .DRIRECTIONAL:
                
                for directFlag in directionalFlags {
                    // if the button state has changed since last evaluation, create event
                    if directFlag.1 == buff[offset.rawValue] && buff[offset.rawValue] != self.controllerBuffer[offset.rawValue] {
                        events.append(ControllerEvent(Name: InputType.Directional, State: directFlag.0, Value: nil, debugByte: buff[offset.rawValue]))
                    }
                }
            case .STRUM:
                for strumbarFlag in strumBarFlags {
                    if  strumbarFlag.1 == buff[offset.rawValue] && buff[offset.rawValue] != self.controllerBuffer[offset.rawValue] {
                        events.append(ControllerEvent(Name: InputType.Strumbar, State: strumbarFlag.0, Value: nil, debugByte: buff[offset.rawValue]))
                    }
                }
            case .VIBRATO:
                self.NOOP()
            case .BATTERY:
                self.NOOP()
            case .GYRO:
                self.NOOP()
            }
        }
        
        self.controllerBuffer = buff
        self.eventList = events
    }
    public func getEvents() -> [ControllerEvent] {
        return self.eventList
    }
    
    private func NOOP() -> Void {
    }
    
    public func dumpBuffer(enumerate: Bool = false) -> Void {
        print(BufferToString(buff: self.controllerBuffer, enumerate: enumerate))
    }
    
    private func bitwiseStateChange(current: UInt8, last: UInt8, flag: UInt8) -> (Bool, Bool) {
        let state: Bool = (current & flag) > 0
        let change: Bool = ((current & flag) ^ (last & flag)) > 0
        return (state, change)
    }
}
