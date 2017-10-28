//
//  AvailableGamesFourImageCell.swift
//  Mememe
//
//  Created by Duy Le on 9/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class AvailableGamesThreeImageCell: UITableViewCell {
    
    @IBOutlet weak var firstIV: UIImageView!
    @IBOutlet weak var secondIV: UIImageView!
    @IBOutlet weak var thirdIV: UIImageView!
    
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


