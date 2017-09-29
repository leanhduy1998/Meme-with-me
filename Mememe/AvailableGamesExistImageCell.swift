//
//  HallOfMememeTableViewCell.swift
//  Mememe
//
//  Created by Duy Le on 7/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class AvailableGamesExistImageCell: UITableViewCell {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
