//
//  InputViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 15/06/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit
import CoreBluetooth

class InputViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var sensorTable: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.inputData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.sensorTable.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = String(Int(appDelegate.inputData[indexPath.row]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.text = String(Int(appDelegate.inputData[indexPath.row]))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
        PARSING SENSOR DATA
        Sensor data is received in 20 byte packets. Button arrays are represented as single UInt8
        (byte) values. The state of each button within the array can be decoded from the UInt8 using
        the AND (&) bitwise operator.
        Where the default value is the set and the flag (or button) to be tested is the offset factor (the ammount by which the flag increases the containing UInt8)
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
