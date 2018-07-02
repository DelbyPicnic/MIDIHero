//
//  MIDISettingsViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 30/06/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit
import CoreMIDI
import CoreData

class MIDISettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var allMIDIDestinations:[MIDIEndpointRef]!
    
    @IBOutlet weak var lblMIDIChannel: UILabel!
    @IBOutlet weak var stpChannelSelect: UIStepper!
    @IBAction func stpChannelSelectDidChange(_ sender: Any) {
        // Update actual MIDI Channel in the application delegate
        appDelegate.activeMIDIChannel = Int(stpChannelSelect.value)
        // Update UI
        lblMIDIChannel.text = ("MIDI Channel: " + String(Int(stpChannelSelect.value)))
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of MIDI destinations
        return MIDIGetNumberOfDestinations()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let endpoint:MIDIEndpointRef = MIDIGetDestination(indexPath.row);
        if (endpoint != 0)
        {
            // Get the destination name
            cell.textLabel?.text = getDisplayName(endpoint);
            // If the destination is the selected destination then set the checkmark
            if(endpoint == appDelegate.activeMIDIEndpoint){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Set MIDI destination in the application deletage
        appDelegate.activeMIDIEndpoint = allMIDIDestinations[indexPath.row]
        
        // Update tableView data
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get all MIDI destinations and add them to array
        let count: Int = MIDIGetNumberOfDestinations();
        for i in 0..<count {
            let endpoint:MIDIEndpointRef = MIDIGetDestination(i);
            if (endpoint != 0)
            {
                if(allMIDIDestinations?.append(endpoint) == nil){
                    allMIDIDestinations = [endpoint]
                }
            }
        }
        // Set stepper value to the active setting within the app delegate
        stpChannelSelect.value = Double(appDelegate.activeMIDIChannel)
        // Set channel indecator label
        lblMIDIChannel.text = ("MIDI Channel: " + String(Int(stpChannelSelect.value)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDisplayName(_ obj: MIDIObjectRef) -> String{
        var param: Unmanaged<CFString>?
        var name: String = "Error";
        
        let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
        if err == OSStatus(noErr)
        {
            name =  param!.takeRetainedValue() as String
        }
        
        return name;
    }
}
