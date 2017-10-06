//
//  AvailableGamesView.swift
//  Mememe
//
//  Created by Duy Le on 10/5/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension AvailableGamesViewController{
    func addPlusBtnAnimation(){
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: [.allowUserInteraction, .autoreverse, UIViewAnimationOptions.repeat], animations: {
            self.addBtn.transform = CGAffineTransform(scaleX: 0.95, y: 1)
            
        },completion: nil)
    }
    func setupUI(){
        addPlusBtnAnimation()
        tableview.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        view.backgroundColor = UIColor.white
        plusBtnView.isHidden = false
        tableview.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }
}
