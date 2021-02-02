//
//  FormRuleView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct RuleView: View {
    var color:Color
    var heading:String
    var subtext:String
    
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(self.color)
                .frame(width: 375, height: 180)
                .shadow(radius: 5)
            VStack {
                HStack {
                    Text(self.heading).font(.title)
                    Spacer()
                }
                Text(self.subtext)
                Spacer()
            }
            .padding()
        }
    }
}

struct RuleAddView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.purple)
                .frame(width: 375, height: 75)
                .shadow(radius: 5)
            Image(systemName: "plus")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(Color.white)
                
        }
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        RuleView(color: Color.blue, heading: "Note 1", subtext: "Fret 0")
            .padding()
        // RuleAddView()
        // .padding()
    }
}
