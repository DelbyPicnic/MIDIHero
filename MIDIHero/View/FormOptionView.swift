//
//  FormOptionView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 01/02/2021.
//

import SwiftUI

struct FormOptionView: View {
    var heading: String
    var checked: Bool
    
    var body: some View {
        HStack {
            Text(self.heading).foregroundColor(Color.black)
            Spacer()
            if self.checked {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.black)
            }
        }
    }
}

struct FormOptionView_Previews: PreviewProvider {
    static var previews: some View {
        FormOptionView(heading: "Option 1", checked: true)
            .previewLayout(.fixed(width: 375, height:60))
            .padding()
    }
}
