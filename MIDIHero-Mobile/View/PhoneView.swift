//
//  MIDIHeroView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct MIDIHeroPhoneView: View {
    @EnvironmentObject var midiHero: MIDIHeroModel
    
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
    @EnvironmentObject var midiHero: MIDIHeroModel
    
    static var previews: some View {
        let midiHero = MIDIHeroModel()
        MIDIHeroPhoneView().environmentObject(midiHero)
    }
}
