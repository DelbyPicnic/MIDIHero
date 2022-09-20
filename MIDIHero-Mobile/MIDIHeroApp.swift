//
//  MIDIHeroApp.swift
//  MIDIHero
//
//  Created by Gordon Swan on 15/01/2021.
//

import SwiftUI

@main
struct MIDIHeroApp: App {
    var bluetoothManager:BluetoothManager = BluetoothManager()
    var midiManager:MIDIManager = MIDIManager()
    
    
    init(){
        print ("[MIDIHero] Starting Application.")
    }
    
    var body: some Scene {
        
        WindowGroup {
            MIDIHeroPhoneView()
                .environmentObject(bluetoothManager)
                .environmentObject(midiManager)
        }
    }
}
