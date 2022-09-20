//
//  DesktopSettingsView.swift
//  MIDIHero-macOS
//
//  Created by Gordon Swan on 17/09/2022.
//

import SwiftUI

struct DesktopSettingsView: View {
    @State var midiDestination: String = ""
    @State var midiChannel: Int = 1
    @State var chordMode: Bool = false
    
    
    var body: some View {
        VStack{
            Text("MIDI Settings").bold()
            HStack {
                Spacer()
                Form {
                    Picker("MIDI Destination:", selection: $midiDestination) {
                        Text("IDAM MIDI Host").tag("one")
                        Text("VCV Rack").tag("two")
                        Text("Network").tag("three")
                    }
                    Picker("MIDI Channel:", selection: $midiChannel) {
                        ForEach(1..<16) {x in 
                            Text(String(x)).tag(x)
                        }
                    }
                }.frame(width: 300, alignment: .top)
                Spacer()
            }
            Spacer()
            HStack {
                Toggle(isOn: $chordMode){
                    Label("Flag", systemImage: "flag.fill")
                }.toggleStyle(.switch)
            }
            
            Spacer()
        }.padding(10).frame(alignment: .leading)
    }
}

struct DesktopSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DesktopSettingsView()
    }
}
