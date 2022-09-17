//
//  MIDIHero_macOSApp.swift
//  MIDIHero-macOS
//
//  Created by Gordon Swan on 16/09/2022.
//

import SwiftUI

@main
struct MIDIHero_macOSApp: App {
    var midiHero:MIDIHeroModel = MIDIHeroModel()
    
    init(){
        print ("[MIDIHero] Starting Application.")
    }
    
    var body: some Scene {
        WindowGroup {
            DesktopView().environmentObject(midiHero).navigationTitle("MIDI Hero")
        }
    }
}
