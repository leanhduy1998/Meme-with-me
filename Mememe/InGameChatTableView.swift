//
//  InGameChatTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatHelper.messages[indexPath.row]
        if(message.senderId == MyPlayerData.id){
            var cell = tableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell") as? MyChatTableViewCell
            cell = CellAnimator.add(cell: cell!)
            cell?.messageTF.text = message.text
            s3Helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
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
            s3Helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                DispatchQueue.main.async {
                    cell?.userIV.image = UIImage(data: imageData)
                }
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHelper.messages.count
    }
}
