//
//  AppDelegate.swift
//  MIDIHero
//
//  Created by Gordon Swan on 14/06/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // CoreBluetooth variables
    var centralMgr: CBCentralManager!       // CentralManager instance
    var bleGuitar: CBPeripheral!            // Connected peripheral instance
    var primaryCharacteristicUUID: CBUUID!  // UUID of the characteristic from which to collect data

    // Input buffer
    
    var inputData = [UInt8]()
    
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

