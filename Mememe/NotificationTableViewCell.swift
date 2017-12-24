//
//  NotificationTableViewCell.swift
//  Mememe
//
//  Created by Duy Le on 12/24/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationLabel: InsetLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
