//
//  OrientSensorTableViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 28/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class OrientSensorTableViewController: UITableViewController {

    @IBOutlet weak var orientSensorToggle: UISwitch!
    @IBAction func switchPositionDidChange(_ sender: Any) {
        // If the switch is thrown, set midihero subsystem value accordingly
        appDelegate.mHero.orientSensorEnabled = orientSensorToggle.isOn
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get pre-stored configuration
        orientSensorToggle.isOn = appDelegate.mHero.orientSensorEnabled
    }
}
