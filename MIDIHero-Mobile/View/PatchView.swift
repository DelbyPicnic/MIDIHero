//
//  PatchView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct PatchView: View {
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 20){
                    ForEach(0..<10){_ in
                        RuleView(color: Color.red, heading: "Rule Name", subtext: "rule details")
                    }
                    RuleAddView()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .navigationBarTitle("Patch Rules")
        }
    }
}

struct PatchView_Previews: PreviewProvider {
    static var previews: some View {
        PatchView()
    }
}
