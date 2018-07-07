//
//  SensorViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 05/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class SensorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let sensorNames:[String] = ["Vibrato Bar", "Orientation"]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellVOAdjust", for: indexPath)
        cell.textLabel?.text = sensorNames[indexPath.row]
        cell.detailTextLabel?.text = try! String(appDelegate.mHero.getRangedSensor(sen: sensorNames[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "sensorAdjust", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         let adjustmentController = segue.destination as! SensorAdjustmentController
         adjustmentController.sensorAdjustment = (self.tableView.indexPathForSelectedRow?.row)!
         adjustmentController.sensorAdjustmentName = sensorNames[(self.tableView.indexPathForSelectedRow?.row)!]
     }

}
