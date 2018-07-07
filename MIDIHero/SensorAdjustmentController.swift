//
//  SensorAdjustmentController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 05/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class SensorAdjustmentController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var sensorAdjustment:Int = 0
    var sensorAdjustmentName:String = "Error"

    @IBOutlet weak var lblController: UILabel!
    @IBOutlet weak var stpCValue: UIStepper!
    @IBAction func stpCValueDidChange(_ sender: Any) {
        
        lblController.text = "Controller Change: " + String(Int(stpCValue.value))
        try! appDelegate.mHero.setRangedSensor(sen: sensorAdjustmentName, val: Int(stpCValue.value))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = sensorAdjustmentName
        lblController.text = "Controller Change: " + String(try! appDelegate.mHero.getRangedSensor(sen: sensorAdjustmentName))
        stpCValue.value = Double(try! appDelegate.mHero.getRangedSensor(sen: sensorAdjustmentName))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
