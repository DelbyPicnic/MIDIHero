//
//  MIDIHero_macOSApp.swift
//  MIDIHero-macOS
//
//  Created by Gordon Swan on 16/09/2022.
//

import SwiftUI

@main
struct MIDIHero_macOSApp: App {
    var bluetoothManager: BluetoothManager
    var midiManager: MIDIManager
    var controllerManager: ControllerManager
    
    init(){
        print ("[MIDIHero] Starting Application.")
        
        self.controllerManager = ControllerManager()
        print("[MIDIHero] Initialising Bluetooth Manager")
        self.bluetoothManager = BluetoothManager(onUpdate: self.controllerManager.DidChangeState)
        print("[MIDIHero] Initialising MIDI Manager")
        self.midiManager = MIDIManager()
        
    }
    
    var body: some Scene {
        WindowGroup {
            DesktopView()
                .environmentObject(bluetoothManager)
                .environmentObject(midiManager)
                .navigationTitle("MIDI Hero")
        }
    }
}
