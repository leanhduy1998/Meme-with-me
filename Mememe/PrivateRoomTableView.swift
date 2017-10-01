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
        
        if(tableView == chatTableView){
            let message = chatHelper.messages[indexPath.row]
            if(message.senderId == MyPlayerData.id){
                var cell = tableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell") as? MyChatTableViewCell
                cell = CellAnimator.add(cell: cell!)
                cell?.messageTF.text = message.text
                helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                    DispatchQueue.main.async {
                        cell?.userIV.image = UIImage(data: imageData)
                    }
                }
                return cell!
            }
            else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "HerChatTableViewCell") as? HerChatTableViewCell
                cell = CellAnimator.add(cell: cell!)
                cell?.messageTF.text = message.text
                helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                    DispatchQueue.main.async {
                        cell?.userIV.image = UIImage(data: imageData)
                    }
                }
                return cell!
            }
        }
        else {
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == chatTableView){
            return chatHelper.messages.count
        }
        else {
            return userInRoom.count
        }
    }
}
