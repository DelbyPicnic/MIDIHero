//
//  SettingsView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct ListRowView: View {
    
    var icon: String
    var iconColor: Color
    var heading: String
    var subtext: String = ""
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(self.iconColor)
                Image(systemName: icon)
                    .foregroundColor(Color.white)
                    .imageScale(.large)
            }
            .frame(width: 36, height: 36, alignment: .center)
            Text(self.heading).foregroundColor(Color.gray)
            Spacer()
            Text(self.subtext)
        }
    }
}


struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(icon: "gear", iconColor: Color.gray, heading: "Application", subtext: "Todo")
            .previewLayout(.fixed(width: 375, height:60))
            .padding()
    }
}

