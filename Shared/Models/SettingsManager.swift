//
//  SettingsManager.swift
//  MIDIHero
//
//  Created by Gordon Swan on 17/09/2022.
//

import Foundation

public enum SettingsManager {
    public enum key: String {
        case Debug = "debug"
        case MIDIDestination = "midiDest"
        case MIDIChannel = "midiChannel"
    }
    
    public static subscript(_ key: key) -> Any? {
        get  {
            return UserDefaults.standard.value(forKey: key.rawValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key.rawValue)
        }
    }
}

extension SettingsManager {
    public static func boolValue(_ key: key) -> Bool {
        if let value = SettingsManager[key] as? Bool {
            return value
        }
        return false
    }
    public static func stringValue(_ key: key) -> String? {
        if let value = SettingsManager[key] as? String {
            return value
        }
        return nil
    }
    public static func intValue(_ key: key) -> Int? {
        if let value = SettingsManager[key] as? Int {
            return value
        }
        return nil
    }
}
