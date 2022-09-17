//
//  DebugNotesView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 04/03/2021.
//

import SwiftUI

struct DebugNotesView: View {
    @EnvironmentObject var midiHero: MIDIHeroModel
    
    var body: some View {
        Form {
            Section(header: Text("Debug Options")){
                Button(action: {
                    midiHero.playNote(note: Note.C3)
                }) {
                    ListRowView(icon: "pianokeys", iconColor: Color.purple, heading: "Note", subtext: "C3")
                }
                Button(action: {
                    midiHero.playNote(note: Note.D3)
                }) {
                    ListRowView(icon: "pianokeys", iconColor: Color.purple, heading: "Note", subtext: "D3")
                }
                Button(action: {
                    midiHero.playNote(note: Note.E3)
                }) {
                    ListRowView(icon: "pianokeys", iconColor: Color.purple, heading: "Note", subtext: "E3")
                }
            }
            .padding(.vertical, 3)

        }
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
    }
}

struct DebugNotesView_Previews: PreviewProvider {
    static var previews: some View {
        DebugNotesView()
    }
}
