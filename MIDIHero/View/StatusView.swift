//
//  ContentView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 15/01/2021.
//

import Combine
import SwiftUI


struct StatusView: View {
    @EnvironmentObject var midiHero: MIDIHeroModel
    
    var body: some View {
        
        VStack {
            Image("BleGuitar")
            Text("\(self.midiHero.cnxStatus)")
                .padding()
            
            ProgressView().frame(width: 40.0, height: 40.0)
            
        }.padding()
    }
}

struct ShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 8.0, x: 2.0, y: 4.0)
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        let midiHero = MIDIHeroModel()
        StatusView().environmentObject(midiHero)
    }
}
