//
//  AvailableGamesTableView.swift
//  Mememe
//
//  Created by Duy Le on 9/17/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit


extension AvailableGameTutorialController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesOneImageCell") as? AvailableGamesOneImageCell)!
        cell = CellAnimator.add(cell: cell)
        cell.nameLabel.text = "A bot's room!"
        cell.activityIndicator.stopAnimating()
            
        cell.imageview.image = #imageLiteral(resourceName: "ichooseyou")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

