//
//  MIDIHero.swift
//  MIDIHero
//
//  Created by Gordon Swan on 02/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import Foundation

// Application Modes
enum appMode: String {
    case GATE
    case STRING
}

// Strum bar input representation
enum strumBar: Int {
    // Raw values are integer representations of the raw byte value from the guitar
    case UP = 255
    case DOWN = 0
    case NULL = 128
}

// Directional input representation
enum directionButtons: Int {
    // Raw values are integer representations of the raw byte value from the guitar
    case UP_RIGHT = 7
    case RIGHT = 6
    case DOWN_RIGHT = 5
    case DOWN = 4
    case DOWN_LEFT = 3
    case LEFT = 2
    case UP_LEFT = 1
    case UP = 0
    case NULL = 15
}
