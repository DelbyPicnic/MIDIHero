//
//  ContentView.swift
//  MIDIHero-macOS
//
//  Created by Gordon Swan on 16/09/2022.
//

import SwiftUI

struct DesktopView: View {
    @EnvironmentObject var midiHero: MIDIHeroModel
    var body: some View {
        NavigationView {
            SidebarView()
            Text("No Message Selection")
        }
    }
}

struct SidebarView: View {
    @State private var isDefaultItemActive = true
    @EnvironmentObject var midiHero: MIDIHeroModel
    
    var body: some View {
        let list = List {
                    NavigationLink(destination: StatusView(), isActive: $isDefaultItemActive) {
                        ListRowView(icon: "house", iconColor: Color.black, heading: "Status")
                    }
                    NavigationLink(destination: DesktopSettingsView()) {
                        ListRowView(icon: "pianokeys", iconColor: Color.black, heading: "MIDI Settings")
                    }
                    NavigationLink(destination: PageView(pageText: "page 2")) {
                        ListRowView(icon: "guitars", iconColor: Color.black, heading: "Controller Settings")
                    }
                    NavigationLink(destination: PageView(pageText: "page 2")) {
                        ListRowView(icon: "dial.fill", iconColor: Color.black, heading: "Patches")
                    }
                    NavigationLink(destination: PageView(pageText: "page 2")) {
                        ListRowView(icon: "questionmark.circle", iconColor: Color.black, heading: "About")
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: 200)

        #if os(macOS)
        list.toolbar {
            Button(action: toggleSidebar) {
                Image(systemName: "sidebar.left")
            }
        }
        #else
        list
        #endif
    }
}

struct PageView: View {
    var pageText = ""
    
    var body: some View {
        Text(pageText)
    }
}

#if os(macOS)
private func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?
        .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
#endif

struct ContentView_Previews: PreviewProvider {
    @EnvironmentObject var midiHero: MIDIHeroModel
    
    
    static var previews: some View {
        let midiHero = MIDIHeroModel()
        
        DesktopView().environmentObject(midiHero)
        
    }
}
