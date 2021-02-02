//
//  LogView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/01/2021.
//

import SwiftUI

struct LogView: View {
    @State private var sysLog: String = "Log.."
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            TextEditor(text: $sysLog)
                .background(Color.white)
                .border(Color.gray, width: 1)
                .font(.custom("Courier New", size: 12))
                    .disabled(true)
        }
    }
    
    public func addLog(line: String){
        self.sysLog = line
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
