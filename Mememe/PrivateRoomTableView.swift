//
//  PrivateRoomTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/25/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit
import SwiftTryCatch

extension PrivateRoomViewController {
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 25.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: view.frame.width - 106, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == chatTableView){
            if(calculateHeight(inString: chatHelper.messages[indexPath.row].text) > 40){
                return calculateHeight(inString: chatHelper.messages[indexPath.row].text)
            }
            else{
                return 40
            }
        }
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == chatTableView){
            let message = chatHelper.messages[indexPath.row]
            if(message.senderId == MyPlayerData.id){
                var cell = tableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell") as? MyChatTableViewCell
                cell = CellAnimator.add(cell: cell!)
                
                cell?.messageTF.text = message.text
                
                cell?.messageTF.layer.masksToBounds = true
                cell?.messageTF.layer.cornerRadius = 5
                
                if userImagesDic[message.senderId] == nil {
                    helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                        DispatchQueue.main.async {
                            cell?.userIV.image = UIImage(data: imageData)
                            self.userImagesDic[message.senderId] = UIImage(data: imageData)
                        }
                    }
                }
                else {
                    cell?.userIV.image = userImagesDic[message.senderId]
                }
                cell?.userIV = CircleImageCutter.roundImageView(imageview: (cell?.userIV)!, radius: 15)
                return cell!
            }
            else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "HerChatTableViewCell") as? HerChatTableViewCell
                cell = CellAnimator.add(cell: cell!)
                
                cell?.messageTF.text = message.text
                cell?.messageTF.numberOfLines = 0
                cell?.messageTF.lineBreakMode = NSLineBreakMode.byWordWrapping
                
                cell?.messageTF.layer.masksToBounds = true
                cell?.messageTF.layer.cornerRadius = 5
                
                if userImagesDic[message.senderId] == nil {
                    helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                        DispatchQueue.main.async {
                            cell?.userIV.image = UIImage(data: imageData)
                            self.userImagesDic[message.senderId] = UIImage(data: imageData)
                        }
                    }
                }
                else {
                    cell?.userIV.image = userImagesDic[message.senderId]
                }
                cell?.userIV = CircleImageCutter.roundImageView(imageview: (cell?.userIV)!, radius: 15)
                return cell!
            }
        }
        else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "PrivateRoomTableCell") as? PrivateRoomTableCell
            cell = CellAnimator.add(cell: cell!)
            
            if(userImagesDic[userInRoom[indexPath.row].userId] != nil){
                cell?.imageview.image = userImagesDic[userInRoom[indexPath.row].userId]!
            }
            else{
                helper.loadUserProfilePicture(userId: userInRoom[indexPath.row].userId) { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        
                        cell?.imageview.image = image
                        if indexPath.row <= (self.userInRoom.count-1){
                            self.userImagesDic[self.userInRoom[indexPath.row].userId] = image
                        }
                    }
                }
            }
            cell?.imageview = CircleImageCutter.roundImageView(imageview: (cell?.imageview)!, radius: 15)
            cell?.nameLabel.text = userInRoom[indexPath.row].userName
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == chatTableView){
            if(chatHelper.messages.count > 0){
                emptyChatLabel.isHidden = true
            }
            else{
                emptyChatLabel.isHidden = false
            }
            return chatHelper.messages.count
        }
        else {
            return userInRoom.count
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if(MyPlayerData.id != leaderId){
                DisplayAlert.display(controller: self, title: "Master Access Denied! Beep! Boop!", message: "You are not the leader of the room.")
                return
            }
            else if userInRoom[indexPath.row].userId == MyPlayerData.id {
                DisplayAlert.display(controller: self, title: "To be kicked, you must first be able to be kicked!", message: "You cannot kick yourself out!")
                return
            }
        availableRoomRef.child(leaderId).child("playerInRoom").child(userInRoom[indexPath.row].userId).removeValue()
            
            self.userInRoom.remove(at: indexPath.row)
            SwiftTryCatch.try({
                self.tableview.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            }, catch: { (error) in
                self.tableview.reloadData()
            }, finally: {
                
            })
        }
    }
}
