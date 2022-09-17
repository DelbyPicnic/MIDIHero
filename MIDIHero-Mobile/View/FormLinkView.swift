//
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct FormLinkView: View {
    
    @Environment(\.openURL) private var openURL
    
    var icon: String
    var color: Color
    var text: String
    var link: String
    
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(self.color)
                Image(systemName: self.icon)
                    .foregroundColor(Color.white)
            }
            .frame(width: 36, height: 36, alignment: .center)
            Text(self.text).foregroundColor(Color.gray)
            Spacer()
            Button(action: {
                if let url = URL(string: link) {
                    openURL(url)
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .accentColor(Color(.systemGray))
        }
    }
}


struct FormLinkView_Previews: PreviewProvider {
    static var previews: some View {
        FormLinkView(icon: "globe", color: Color.blue, text: "Application", link: "Todo")
            .previewLayout(.fixed(width: 375, height:60))
            .padding()
    }
}


