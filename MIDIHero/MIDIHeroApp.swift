//
//  MIDIHeroApp.swift
//  MIDIHero
//
//  Created by Gordon Swan on 15/01/2021.
//

import SwiftUI

@main
struct MIDIHeroApp: App {
    var midiHero:MIDIHeroModel = MIDIHeroModel()
    
    init(){
        print ("[MIDIHero] Starting Application.")
    }
    
    var body: some Scene {
        
        WindowGroup {
            MIDIHeroView().environmentObject(midiHero)
        }
    }
}
