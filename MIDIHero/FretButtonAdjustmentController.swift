//
//  FretButtonAdjustmentController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 03/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class FretButtonAdjustmentController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var btnAdjustment:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Adjust Fret Button " + String(btnAdjustment + 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mHero.countNotes()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNote = indexPath.row + appDelegate.mHero.getMin()
        try! appDelegate.mHero.setFretBtnNote(btn: btnAdjustment, note: selectedNote)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTitle:String = appDelegate.mHero.allNotes()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoteValue", for: indexPath)
        do {
            cell.textLabel?.text = cellTitle
            if(try appDelegate.mHero.getFretBtnNote(btn: btnAdjustment) == cellTitle){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }catch{
            cell.textLabel?.text = cellTitle
        }
        return cell
    }
}
