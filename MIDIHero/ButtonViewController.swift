//
//  ButtonViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 19/06/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {

    @IBOutlet weak var txtBtnStatus: UITextView!
    @IBOutlet weak var barVibratoValue: UIProgressView!
    @IBOutlet weak var barOrientValue: UIProgressView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ButtonViewController.updateUIValues), name: NSNotification.Name(rawValue: didUpdateBluetoothData), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateUIValues(){
        var txtStatus:String = ""
        
        // Get pressed frets
        for (index, flag) in fretBtnFlags.enumerated(){
            if(flag & appDelegate.inputData[0] != 0b00000000){
                txtStatus.append("Fret button " + String(index) + " pressed.\n")
            }
        }
        // Get pressed system buttons
        for flag in sysBtnFlags{
            if(flag & appDelegate.inputData[1] != 0b00000000){
                switch flag{
                case 0b00000010:
                    txtStatus.append("Sys button PAUSE pressed.\n")
                case 0b00000100:
                    txtStatus.append("Sys button ACTION pressed.\n")
                case 0b00001000:
                    txtStatus.append("Sys button BRIDGE pressed.\n")
                case 0b00010000:
                    txtStatus.append("Sys button PWR pressed.\n")
                default:
                    txtStatus.append("")
                }
            }
        }
        
        // Get direction buttons
        switch Int(appDelegate.inputData[2]){
        case 0:
            txtStatus.append("UP\n")
        case 1:
            txtStatus.append("UP LEFT\n")
        case 2:
            txtStatus.append("LEFT\n")
        case 3:
            txtStatus.append("DOWN LEFT\n")
        case 4:
            txtStatus.append("DOWN\n")
        case 5:
            txtStatus.append("DOWN RIGHT\n")
        case 6:
            txtStatus.append("RIGHT\n")
        case 7:
            txtStatus.append("UP RIGHT\n")
        default:
            txtStatus.append("")
        }
        
        // Get strumbar position
        if (Int(appDelegate.inputData[4]) > 128){
            txtStatus.append("Strum Bar DOWN\n")
        }else if(Int(appDelegate.inputData[4]) < 128){
            txtStatus.append("Strum Bar UP\n")
        }else{
            txtStatus.append("Strum Bar CENTER\n")
        }
        
        // Get Battery Level
        let batLevel:Int = ((Int(appDelegate.inputData[18])*10) - 128)/(255-128)
        txtStatus.append("Battery Level: " + String(batLevel) + "%")
        
        txtBtnStatus.text = txtStatus
        
        // Update vibrato bar status
        let vStatus:Float = Float(appDelegate.inputData[6])
        barVibratoValue.progress = mapToProgressBarRange(minValue: 128.0, maxValue: 255.0, curValue: vStatus)
        // Update orientation bar status
        let oStatus:Float = Float(appDelegate.inputData[19])
        barOrientValue.progress = mapToProgressBarRange(minValue: 0.0, maxValue: 255.0, curValue: oStatus)
    }
    
    func mapToProgressBarRange(minValue:Float, maxValue:Float, curValue:Float)->Float{
        return Float( (curValue - minValue)/(maxValue-minValue) )
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
