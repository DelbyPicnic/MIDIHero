//
//  MIDISettingsView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 01/02/2021.
//

import SwiftUI

struct MIDISettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("MIDI Destinations")){
                ListRowView(icon: "flag", iconColor: Color.purple, heading: "Version", subtext: "2.0")
                FormLinkView(icon: "globe", color: Color.blue, text: "Blackfeet UK", link: "https://gps.co.uk")
            }
            .padding(.vertical, 3)

        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
    }
}

struct MIDISettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MIDISettingsView()
    }
}
