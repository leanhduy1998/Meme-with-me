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
     
        var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesExistImageCell") as? AvailableGamesExistImageCell)!
        cell = CellAnimator.add(cell: cell)
        cell.nameLabel.text = "A bot's room!"
        cell.activityIndicator.startAnimating()
            
        cell.imageview.image = #imageLiteral(resourceName: "ichooseyou")
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

