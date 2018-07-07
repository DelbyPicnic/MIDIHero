//
//  TriggerSettingsViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 02/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit


class TriggerSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let TriggerModes:[String] = ["Gate Mode","Strings Mode"]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TriggerModes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTriggerType", for: indexPath)
        cell.textLabel?.text = TriggerModes[indexPath.row]
        
        if(appDelegate.activeTriggerMode.rawValue == TriggerModes[indexPath.row]){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            appDelegate.activeTriggerMode = .GATE
        case 1:
            appDelegate.activeTriggerMode = .STRING
        default:
            // Default to gate mode
            appDelegate.activeTriggerMode = .GATE
        }
        
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
