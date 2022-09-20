//
//  BluetoothManager.swift
//  MIDIHero
//
//  Created by Gordon Swan on 17/09/2022.
//

import Foundation
import CoreBluetooth

final class BluetoothManager: NSObject, ObservableObject {
    
    @Published var connectionStatus = "Initialising"
    @Published var signalStrength = 0.0
    
    // CoreBluetooth vars
    private var centralManager: CBCentralManager!
    private var guitarController: CBPeripheral!
    private var targetCharacteristicUUID: CBUUID!
    
    // Update callback reference
    private var _callback: ([UInt8])->()
    
    // Input buffer (8 bits x 20) 20 Bytes
    private var inputLast:[UInt8] = Array(repeating: 0b00000000, count: 20)
    
    init(onUpdate: @escaping ([UInt8])->()) {
        self._callback = onUpdate
        // initialise CoreBluetooth
        super.init()
        if (self.centralManager == nil){
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    override init() {
        self._callback = {(_: [UInt8])->() in }
        super.init()
        if (self.centralManager == nil){
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }

    private func resetBluetoothManager() -> Void {
        self.connectionStatus = "Searching For Guitar"
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Manage CM state
        switch central.state {
        case .unknown:
            self.connectionStatus = "Unknown State"
            print ("[CBCentralManager] State is unknown")
        case .resetting:
            self.connectionStatus = "Resetting..."
            print ("[CBCentralManager] Resetting...")
        case .unsupported:
            self.connectionStatus = "Bluetooth Error 1"
            print ("[CBCentralManager][Error] State not supported")
        case .unauthorized:
            self.connectionStatus = "Bluetooth Error 2"
            print ("[CBCentralManager][Error] State not authorized")
        case .poweredOff:
            // Bluetooth is not enabled.
            self.connectionStatus = "Bluetooth Is Turned Off"
            print ("[CBCentralManager] Inactive")
        case .poweredOn:
            // Bluetooth is enabled, start scanning for devices
            self.connectionStatus = "Searching For Guitar"
            print ("[CBCentralManager] Active, will begin scan")
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print ("[CBCentralManager][Error] An unknown bluetooth state has been encountered")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Detect and connect bluetooth devices
        if (peripheral.name == "Ble Guitar"){
            print ("[CBCentralManager] Detected controller. Connecting...")
            
            // Controller detected. Stop scan.
            self.guitarController = peripheral
            self.guitarController.delegate = self
            self.centralManager.stopScan()
            
            // Connect to controller
            self.centralManager.connect(self.guitarController, options:nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // CM connected to controller successfully
        print ("[CBCentralManager] Connected. Interrogating...")
        
        // Interrogate controller for services
        self.guitarController.discoverServices(nil)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Controller has disconnected. Dispose of peripheral.
        self.guitarController = nil
        print ("[CBCentralManager] Controller has disconnected.")
        
        // Call MIDI Panic to drop all open MIDI notes.
        // Begin searching for contaollers again
        self.resetBluetoothManager()
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Handle each advertised service and interrogate for characteristics
        guard let services = peripheral.services else { return }
        
        for svc in services {
            peripheral.discoverCharacteristics(nil, for: svc)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Handle each advertised characteristic and store ref
        guard let characteristics = service.characteristics else { return }
        
        for chc in characteristics {
            if chc.properties.contains(.notify) {
                self.connectionStatus = "Connected!"
                print ("[CBCentralManager] Connection online.")
                self.targetCharacteristicUUID = chc.uuid
                peripheral .setNotifyValue(true, for: chc)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Handle controller state update notification
        if (characteristic.uuid == self.targetCharacteristicUUID) {
            guard let rawBroadcast = characteristic.value else { return }
            let inputBuffer = [UInt8](rawBroadcast)
            
            self._callback(inputBuffer)
            
            self.inputLast = inputBuffer
        } else {
            print ("[CBCentralManager][Error] An unknown controller characteristic has been encountered.")
        }
    }
}
