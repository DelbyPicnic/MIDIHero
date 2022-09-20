//
//  Utils.swift
//  MIDIHero
//
//  Created by Gordon Swan on 19/09/2022.
//

import Foundation

func ByteToString(byte : UInt8, toSize: Int) -> String {
  var padded = String(byte, radix: 2)
  for _ in 0..<(toSize - padded.count) {
    padded = "0" + padded
  }
    return padded
}

func BufferToString(buff: [UInt8], enumerate: Bool = false) -> String {
    var strBuff: String = ""
    for (i, byte) in buff.enumerated() {
        var row: String = ""
        if enumerate {
            row += "\(i):\t"
        }
        row += String("\(ByteToString(byte: byte, toSize: 8))\n")
        strBuff += row
    }
    return strBuff
}
