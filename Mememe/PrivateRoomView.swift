//
//  PrivateRoomView.swift
//  Mememe
//
//  Created by Duy Le on 10/11/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension PrivateRoomViewController{
    func setBackground(){
        var random = Int(arc4random_uniform(UInt32(11)))
        random += 1
        let imageName = "floor\(random)"
        backgroundIV.image = UIImage(named: imageName)
        
        tableview.backgroundColor = UIColor.clear
        chatTableView.backgroundColor = UIColor.clear
    }
    func setupUI(){
        setBackground()
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        emptyChatLabel.layer.masksToBounds = true
        emptyChatLabel.layer.cornerRadius = 5
        emptyChatLabel.backgroundColor = UIColor.white
        
        tableview.allowsSelection = false
        chatTableView.allowsSelection = false
        
        chatSendBtn.layer.cornerRadius = 5
    }
}