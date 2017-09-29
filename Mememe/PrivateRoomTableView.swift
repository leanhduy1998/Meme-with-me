//
//  PrivateRoomTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/25/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension PrivateRoomViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "PrivateRoomTableCell") as? PrivateRoomTableCell
        cell = CellAnimator.add(cell: cell!)
        helper.loadUserProfilePicture(userId: userInRoom[indexPath.row].userId) { (imageData) in
            DispatchQueue.main.async {
                cell?.imageview.image = UIImage(data: imageData)
            }
        }
        
        cell?.nameLabel.text = userInRoom[indexPath.row].userName
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInRoom.count
    }
}
