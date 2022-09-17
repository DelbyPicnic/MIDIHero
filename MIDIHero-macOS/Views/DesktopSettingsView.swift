//
//  DesktopSettingsView.swift
//  MIDIHero-macOS
//
//  Created by Gordon Swan on 17/09/2022.
//

import SwiftUI

struct DesktopSettingsView: View {
    @State var midiDestination: String = ""
    
    
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
                }.frame(width: 300, alignment: .top)
                Spacer()
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
