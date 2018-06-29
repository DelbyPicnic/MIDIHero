//
//  midiChannelCellView.swift
//  MIDIHero
//
//  Created by Gordon Swan on 29/06/2018.
//  Copyright © 2018 Gordon Swan. All rights reserved.
//

import UIKit

class midiChannelCellView: UITableViewCell {

    @IBOutlet weak var lblChannel: UILabel!
    @IBOutlet weak var stpChannel: UIStepper!
    @IBAction func stpChannelValueDidChange(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
