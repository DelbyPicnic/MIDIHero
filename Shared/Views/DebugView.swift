//
//  DebugView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 19/09/2022.
//

import SwiftUI

struct DebugView: View {
    private var log:LogView = LogView()
    
    var body: some View {
        VStack {
            log
            Form {
                HStack{
                    Button(action: self.noop) {
                        Text("Dump Controller Buffer")
                    }
                    Button(action: self.noop) {
                        Text("Dump MIDI Buffer")
                    }
                }
            }
            Spacer()
        }
    }
    private func noop() -> Void {
        log.addLog(line: "test")
    }
}

struct LogView: View {
    @State private var sysLog: String = ""
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            TextEditor(text: $sysLog)
                .background(Color.white)
                .border(Color.gray, width: 1)
                .font(.custom("Courier New", size: 12))
                    .disabled(true)
        }.padding(5)
    }
    public func addLog(line: String) -> Void {
        sysLog += String("\(line)\n")
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
