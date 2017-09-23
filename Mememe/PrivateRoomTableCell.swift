//
//  PrivateRoomTableCell.swift
//  Mememe
//
//  Created by Duy Le on 8/25/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PrivateRoomTableCell: UITableViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
