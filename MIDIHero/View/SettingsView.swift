//
//  SettingsView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Form {
                    Section(header: Text("Settings")){
                        NavigationLink(destination:MIDISettingsView()){
                            FormRowView(icon: "pianokeys", iconColor: Color.red, heading: "MIDI Settings")
                        }
                        NavigationLink(destination: ControllerSettingsView()){
                            FormRowView(icon: "guitars", iconColor: Color.red, heading: "Controller Settings")
                        }
                    }
                    .padding(.vertical, 3)
                    Section(header: Text("About")){
                        FormRowView(icon: "flag", iconColor: Color.purple, heading: "Version", subtext: "2.0")
                        FormLinkView(icon: "globe", color: Color.blue, text: "Blackfeet UK", link: "https://boards.4channel.org")
                    }
                    .padding(.vertical, 3)
                    Text("©2021 Blackfeet UK")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .padding(.top, 6)
                        .padding(.bottom, 10)
                        .foregroundColor(Color.secondary)
                }
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
                
            }
            .navigationBarTitle("Settings")
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
