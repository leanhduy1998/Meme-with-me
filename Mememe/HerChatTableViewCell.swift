//
//  HerChatTableViewCell.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class HerChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTF: UILabel!
    
    @IBOutlet weak var userIV: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageTF.numberOfLines = 0
        messageTF.lineBreakMode = NSLineBreakMode.byWordWrapping
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
