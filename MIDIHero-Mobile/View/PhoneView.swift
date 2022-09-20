//
//  MIDIHeroView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct MIDIHeroPhoneView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var midiManager: MIDIManager
    
    var body: some View {
        
        TabView {
            StatusView()
                .tabItem {
                    Image(systemName: "dot.radiowaves.left.and.right")
                    Text("Connections")
                }
            PatchView()
                .tabItem {
                    Image(systemName: "dial.fill")
                    Text("Patch")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct MIDIHeroView_Previews: PreviewProvider {
    static var previews: some View {
        let bluetoothManager: BluetoothManager = BluetoothManager()
        let midiManager: MIDIManager = MIDIManager()
        
        MIDIHeroPhoneView()
            .environmentObject(bluetoothManager)
            .environmentObject(midiManager)
        
    }
}
