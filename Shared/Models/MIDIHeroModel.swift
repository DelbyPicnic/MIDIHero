//
//  MIDIHeroModel.swift
//  MIDIHero
//
//  Created by Gordon Swan on 17/01/2021.
//

import Foundation
import CoreBluetooth

enum MIDIHeroError:Error {
    case UnknownControllerEvent
}

final class MIDIHeroModel: NSObject, ObservableObject {
    @Published var cnxStatus = "Initialising"
    @Published var cnxSignal = 0.0
    
    // CoreBluetooth vars
    private var centralManager: CBCentralManager!
    private var bleGuitar: CBPeripheral!
    private var targetCharacteristicUUID: CBUUID!
    
    // MDInterface
    private let mdi:MDInterface = MDInterface.shared
    
    // Input buffer (8 bits x 20) 20 Bytes
    private var inputLast:[UInt8] = Array(repeating: 0b00000000, count: 20)
    
    // Ruleset
    private var rules:[Rule] = [Rule]()
    
    // MinMax Midi notes (B0 -> A4)
    let MIDINoteRange = (min: 35, max: 81)
    
    
    override init(){
        do {
            self.rules = [
                try NoteRule(name: "Fret 1 Up", parameter: "fret_0", notes: [Note.C3], activator: StrumDirection.StrumUP),
                try NoteRule(name: "Fret 1 Down", parameter: "fret_0", notes: [Note.C2], activator: StrumDirection.StrumDown),
                
                try NoteRule(name: "Fret 2 Up", parameter: "fret_1", notes: [Note.E3], activator: StrumDirection.StrumUP),
                try NoteRule(name: "Fret 2 Down", parameter: "fret_1", notes: [Note.E2], activator: StrumDirection.StrumDown),
                
                try NoteRule(name: "Fret 3 Up", parameter: "fret_2", notes: [Note.G3], activator: StrumDirection.StrumUP),
                try NoteRule(name: "Fret 3 Down", parameter: "fret_2", notes: [Note.G2], activator: StrumDirection.StrumDown),
                
                try NoteRule(name: "Fret 4 Up", parameter: "fret_3", notes: [Note.D3], activator: StrumDirection.StrumUP),
                try NoteRule(name: "Fret 4 Down", parameter: "fret_3", notes: [Note.D2], activator: StrumDirection.StrumDown),
                
                try NoteRule(name: "Fret 5 Up", parameter: "fret_4", notes: [Note.F3], activator: StrumDirection.StrumUP),
                try NoteRule(name: "Fret 5 Down", parameter: "fret_4", notes: [Note.F2], activator: StrumDirection.StrumDown),
                
                try NoteRule(name: "Fret 6 Up", parameter: "fret_5", notes: [Note.A3], activator: StrumDirection.StrumUP),
                try NoteRule(name: "Fret 6 Down", parameter: "fret_5", notes: [Note.A2], activator: StrumDirection.StrumDown)
            ]
        } catch RuleTypeError.ControllerFlagNotRecognised {
            print ("[MIDIHero][Error] Could not create rule: Controller flag not recognised")
        } catch RuleTypeError.MIDIMessageNotRecognised {
            print ("[MIDIHero][Error] Could not create rule: MIDI Message not recognised")
        } catch RuleTypeError.NoteNotRecognised {
            print ("[MIDIHero][Error] Could not create rule: MIDI Note not recognisd")
        } catch {
            print ("[MIDIHero][Error] An unknown error occured: \(error)")
        }
        
        super.init()
        // Initialise CoreBluetooth
        if (self.centralManager == nil) {
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func round(_ value:Float) -> Float { return floor(value + 0.5) }
    
    func playNote(note: Note){
        self.mdi.notesOn(notes: [note], value: 64)
    }
}

extension MIDIHeroModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Manage CM state based on state
        switch central.state {
        case .unknown:
            self.cnxStatus = "Unknown State"
            print ("[CBCentralManager] State is unknown")
        case .resetting:
            self.cnxStatus = "Resetting..."
            print ("[CBCentralManager] Resetting...")
        case .unsupported:
            self.cnxStatus = "Bluetooth Error 1"
            print ("[CBCentralManager][Error] State not supported")
        case .unauthorized:
            self.cnxStatus = "Bluetooth Error 2"
            print ("[CBCentralManager][Error] State not authorized")
        case .poweredOff:
            // Bluetooth is not enabled.
            self.cnxStatus = "Bluetooth Is Turned Off"
            print ("[CBCentralManager] Inactive")
        case .poweredOn:
            // Bluetooth is enabled, start scanning for devices
            self.cnxStatus = "Searching For Guitar"
            print ("[CBCentralManager] Active, will begin scan")
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print ("[CBCentralManager][Error] An unknown bluetooth state has been encountered")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Detect and connect bluetooth devices
        if (peripheral.name == "Ble Guitar"){
            self.cnxStatus = "Detected Guitar"
            print ("[CBCentralManager] Detected controller. Connecting...")
            
            // Controller detected. Stop scan.
            self.bleGuitar = peripheral
            self.bleGuitar.delegate = self
            self.centralManager.stopScan()
            
            // Connect to controller
            self.centralManager.connect(self.bleGuitar, options:nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // CM connected to controller successfully
        print ("[CBCentralManager] Connected. Interrogating...")
        
        // Interrogate controller for services
        self.bleGuitar.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Controller has disconnected. Dispose of peripheral.
        self.bleGuitar = nil
        print ("[CBCentralManager] Controller has disconnected.")
        
        // Call MIDI Panic to drop all open MIDI notes.
        // Begin searching for contaollers again
    }
}

extension MIDIHeroModel: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Handle each advertised service and interrogate for characteristics
        guard let services = peripheral.services else { return }
        
        for svc in services {
            peripheral.discoverCharacteristics(nil, for: svc)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Handle each advertised characteristic and store ref
        guard let characteristics = service.characteristics else { return }
        
        for chc in characteristics {
            if chc.properties.contains(.notify) {
                self.cnxStatus = "Connected!"
                print ("[CBCentralManager] Connection online.")
                self.targetCharacteristicUUID = chc.uuid
                peripheral .setNotifyValue(true, for: chc)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Handle controller state update notification
        if (characteristic.uuid == self.targetCharacteristicUUID) {
            guard let rawBroadcast = characteristic.value else { return }
            let inputBuffer = [UInt8](rawBroadcast)
            
            for rule in rules {
                rule.process(stateCurrent: inputBuffer, stateLast: inputLast,  mdi: mdi)
            }
            
            self.inputLast = inputBuffer
        } else {
            print ("[CBCentralManager][Error] An unknown controller characteristic has been encountered.")
        }
    }
}
