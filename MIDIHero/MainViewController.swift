//
//  ViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 14/06/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit
import CoreBluetooth

// Guitar button bitwise flag definitions
// Ordered: Btn0 -> Btn5
let fretFlags:[(String,UInt8)] = [("btn3",0b00000001), ("btn0",0b00000010), ("btn1",0b00000100), ("btn2",0b00001000), ("btn4",0b00010000), ("btn5",0b00100000)]
// Ordered: PWR, BRIDGE, PAUSE, ACTION
let sysFlags:[(String, UInt8)] = [("PAUSE",0b00000010), ("ACTION",0b00000100), ("BRIDGE", 0b00001000), ("POWER",0b00010000)]

// Input buffers
var fretBtnBuffer:UInt8 = 0b00000000
var sysBtnBuffer:UInt8 = 0b00000000


class MainViewController: UIViewController {
    
    @IBOutlet weak var connectInfo: UILabel!
    @IBOutlet weak var connectStatus: UIActivityIndicatorView!
    @IBOutlet weak var btnShowSensorData: UIButton!
    @IBOutlet weak var btnShowAllInput: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init core bluetooth
        if(appDelegate.centralMgr == nil){
            // Central manager has not been initialised; start central manager
            appDelegate.centralMgr = CBCentralManager(delegate: self, queue: nil)
        }
        if(appDelegate.bleGuitar != nil){
            // If a pre-existing connection is already active then update UI state
            connectInfo.text = "Connected to: " + appDelegate.bleGuitar.name!
            btnShowSensorData.isEnabled = true
            btnShowAllInput.isEnabled = true
            connectStatus.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("central.state is unknown!")
        case .resetting:
            print("central.state is resetting!")
        case .unsupported:
            print("central.state is unsupported!")
        case .unauthorized:
            print("central.state is unauthorized!")
        case .poweredOff:
            // Bluetooth is disabled, tell user to enable bluetooth
            connectInfo.text = "Bluetooth is not enabled!"
            connectStatus.stopAnimating()
            btnShowAllInput.isEnabled = false
            btnShowSensorData.isEnabled = false
            print("central.state is powered off!")
        case .poweredOn:
            // Bluetooth is enabled, scan for hardware
            connectInfo.text = "Searching for Guitar"
            connectStatus.startAnimating()
            print("central manager is powered on!")
            appDelegate.centralMgr.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "Ble Guitar"){
            // Bluetooth Guitar has been found
            appDelegate.bleGuitar = peripheral
            appDelegate.bleGuitar.delegate = self
            appDelegate.centralMgr.stopScan()
            
            connectInfo.text = "Bluetooth Guitar Detected!"
            
            // Try to connect to bluetooth guitar
            appDelegate.centralMgr.connect(appDelegate.bleGuitar, options: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectInfo.text = "Connected to: " + peripheral.name!
        connectStatus.stopAnimating()
        appDelegate.bleGuitar.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        appDelegate.bleGuitar = nil
        connectInfo.text = "Searching for Guitar"
        connectStatus.startAnimating()
        btnShowAllInput.isEnabled = false
        btnShowSensorData.isEnabled = false
    }
}

extension MainViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for charac in characteristics{
            if charac.properties.contains(.notify) {
                
                print("Found characteristic")
                btnShowSensorData.isEnabled = true
                btnShowAllInput.isEnabled = true
                appDelegate.primaryCharacteristicUUID = charac.uuid
                
                peripheral.setNotifyValue(true, for: charac)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
            case appDelegate.primaryCharacteristicUUID:
                guard let characData = characteristic.value else { return }
                
                // Save incoming bluetooth data in app delegate buffer
                let inputData:[UInt8] = [UInt8](characData)
            
                // Convert incoming data into button event triggers
                // Get Fret Button events
                for (index,flag) in fretFlags.enumerated(){
                    let dSTAT:UInt8 = inputData[0] & flag.1
                    let bSTAT:UInt8 = fretBtnBuffer & flag.1
                    if(dSTAT > bSTAT){
                        // Button pressed
                        appDelegate.mHero.fretPressed(fret: index)
                    }else if(bSTAT > dSTAT){
                        // Button depressed
                        appDelegate.mHero.fretDepressed(fret: index)
                    }
                }
                fretBtnBuffer = inputData[0]
                
                // Get System Button events
                for flag in sysFlags{
                    let dSTAT:UInt8 = inputData[1] & flag.1
                    let bSTAT:UInt8 = sysBtnBuffer & flag.1
                    if(dSTAT > bSTAT){
                        // Button pressed
                        print(flag.0 + " PRESSED")
                    }else if(bSTAT > dSTAT){
                        // Button depressed
                        print(flag.0 + " DEPRESSED")
                    }
                }
                sysBtnBuffer = inputData[1]
            
                // Get strumbar position
                if (Int(inputData[4]) > 128){
                    appDelegate.mHero.playNotes()
                }else if(Int(inputData[4]) < 128){
                    appDelegate.mHero.playNotes()
                }
            
            default:
                print("Unhandled Characteristic UUID: " + characteristic.uuid.uuidString)
        }
    }
}

