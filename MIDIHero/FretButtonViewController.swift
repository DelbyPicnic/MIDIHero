//
//  FretButtonViewController.swift
//  MIDIHero
//
//  Created by Gordon Swan on 03/07/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class FretButtonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFretBtn", for: indexPath)
        do {
            cell.textLabel?.text = "Fret Button " + String(indexPath.row + 1)
            cell.detailTextLabel?.text = try appDelegate.mHero.getFretBtnNote(btn: indexPath.row)
        }catch{
            cell.textLabel?.text = "Fret Button " + String(indexPath.row + 1)
            cell.detailTextLabel?.text = "¯\\_(ツ)_/¯"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fretButtonAdjust", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let adjustmentController = segue.destination as! FretButtonAdjustmentController
        adjustmentController.btnAdjustment = (self.tableView.indexPathForSelectedRow?.row)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
