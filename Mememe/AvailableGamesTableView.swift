//
//  AvailableGamesTableView.swift
//  Meme with Me
//
//  Created by Duy Le on 9/17/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit
import SwiftTryCatch

extension AvailableGamesViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = openRooms[indexPath.row]
        
        //if room.roomImageUrl! == "noURL" && (room.playerInRoom?.count)! == 2 {
        if (room.playerInRoom?.count)! == 1 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesOneImageCell") as? AvailableGamesOneImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.imageview.image = nil
            
            cell.activityIndicator.startAnimating()
            
            for (playerId,_) in room.playerInRoom! {
                self.helper.loadUserProfilePicture(userId: (playerId), completeHandler: { (imageData) in
                    DispatchQueue.main.async{
                        let image = UIImage(data: imageData)
                        cell.imageview.image = image
                        cell.activityIndicator.stopAnimating()
                        
                    }
                })
                cell.imageview = UIImageViewHelper.roundImageView(imageview: cell.imageview, radius: 15)
                return cell
            }
        }
        else if (room.playerInRoom?.count)! == 2 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesTwoImageCell") as? AvailableGamesTwoImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.firstIV.image = nil
            cell.secondIV.image = nil
            
            cell.activityIndicator.startAnimating()
            
            cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 15)
            cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 15)
            
            let players = Array((room.playerInRoom?.keys)!)
            
            var firstLoaded = false
            var secondLoaded = false
            
            helper.loadUserProfilePicture(userId: players[0], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.firstIV.image = image
                    firstLoaded = true
                    if(secondLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            helper.loadUserProfilePicture(userId: players[1], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.secondIV.image = image
                    secondLoaded = true
                    if(firstLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })

            
            return cell
        }
        else if (room.playerInRoom?.count)! == 3 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesThreeImageCell") as? AvailableGamesThreeImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.firstIV.image = nil
            cell.secondIV.image = nil
            cell.thirdIV.image = nil
            
            cell.activityIndicator.startAnimating()
            
            cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 15)
            cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 15)
            cell.thirdIV = UIImageViewHelper.roundImageView(imageview: cell.thirdIV, radius: 15)
            
            var firstLoaded = false
            var secondLoaded = false
            var thirdLoaded = false
            
            let players = Array((room.playerInRoom?.keys)!)
            
            helper.loadUserProfilePicture(userId: players[0], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.firstIV.image = image
                    firstLoaded = true
                    if(secondLoaded&&thirdLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            helper.loadUserProfilePicture(userId: players[1], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.secondIV.image = image
                    secondLoaded = true
                    if(firstLoaded&&thirdLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            helper.loadUserProfilePicture(userId: players[2], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.thirdIV.image = image
                    thirdLoaded = true
                    if(firstLoaded&&secondLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            
            return cell
        }
        else if (room.playerInRoom?.count)! >= 4 {
            
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesFourImageCell") as? AvailableGamesFourImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.activityIndicator.startAnimating()
            
            cell.firstIV.image = nil
            cell.secondIV.image = nil
            cell.thirdIV.image = nil
            cell.fourthIV.image = nil
            
            cell.firstIV = UIImageViewHelper.roundImageView(imageview: cell.firstIV, radius: 15)
            cell.secondIV = UIImageViewHelper.roundImageView(imageview: cell.secondIV, radius: 15)
            cell.thirdIV = UIImageViewHelper.roundImageView(imageview: cell.thirdIV, radius: 15)
            cell.fourthIV = UIImageViewHelper.roundImageView(imageview: cell.fourthIV, radius: 15)
            
            let players = Array((room.playerInRoom?.keys)!)
            
            var firstLoaded = false
            var secondLoaded = false
            var thirdLoaded = false
            var fourthLoaded = false
    
            helper.loadUserProfilePicture(userId: players[0], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.firstIV.image = image
                    firstLoaded = true
                    if(thirdLoaded&&secondLoaded&&fourthLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            helper.loadUserProfilePicture(userId: players[1], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.secondIV.image = image
                    secondLoaded = true
                    if(thirdLoaded&&firstLoaded&&fourthLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            helper.loadUserProfilePicture(userId: players[2], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.thirdIV.image = image
                    thirdLoaded = true
                    if(secondLoaded&&firstLoaded&&fourthLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            helper.loadUserProfilePicture(userId: players[3], completeHandler: { (imageData) in
                DispatchQueue.main.async{
                    let image = UIImage(data: imageData)
                    cell.fourthIV.image = image
                    fourthLoaded = true
                    if(secondLoaded&&firstLoaded&&thirdLoaded){
                        cell.activityIndicator.stopAnimating()
                    }
                }
            })
            
            return cell
        }
        else {
            return UITableViewCell()
        }
        
        var cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserOnlineSystem.getUserOnlineStatus(userId: openRooms[indexPath.row].leaderId!) { (isLeaderOnline) in
            DispatchQueue.main.async {
                if isLeaderOnline {
                    if indexPath.row > (self.openRooms.count - 1){
                        return
                    }
                    if self.openRooms[indexPath.row].roomIsOpen == "true"{
                        self.selectedLeaderId = self.openRooms[indexPath.row].leaderId
                        
                        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.none
                        self.availableRoomRef.removeAllObservers()
                        
                        let oldFrame = tableView.visibleCells[indexPath.row].frame
                        
                        /*
                        UIView.animate(withDuration: 1, animations: {
                            tableView.backgroundColor = UIColor.black
                            //tableView.visibleCells[indexPath.row].frame.origin.x = self.view.frame.midX 
                            tableView.visibleCells[indexPath.row].frame.origin.y = self.view.frame.midY - tableView.visibleCells[indexPath.row].frame.height
                            tableView.visibleCells[indexPath.row].transform = CGAffineTransform(scaleX: 2, y: 2)
                            self.tabBarController?.tabBar.barTintColor = UIColor.black
                            self.view.backgroundColor = UIColor.black
                        }, completion: { (completed) in
                            if completed {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "PrivateRoomViewControllerSegue", sender: self)
                                    tableView.visibleCells[indexPath.row].frame = oldFrame
                                }
                            }
                        })*/
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "PrivateRoomViewControllerSegue", sender: self)
                            tableView.visibleCells[indexPath.row].frame = oldFrame
                        }
                    }
                    else {
                        DisplayAlert.display(controller: self, title: "Room is closed", message: "This room has already started the game!")
                        self.openRooms.remove(at: indexPath.row)
                        SwiftTryCatch.try({
                            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
                        }, catch: { (error) in
                            self.tableview.reloadData()
                        }, finally: {
                            // close resources
                        })
                    }
                }
                else {
                    var count = 0
                    for r in self.openRooms {
                        if r.leaderId == self.openRooms[indexPath.row].leaderId {
                            self.openRooms.remove(at: count)
                            SwiftTryCatch.try({
                                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
                            }, catch: { (error) in
                                self.tableview.reloadData()
                            }, finally: {
                                // close resources
                            })
                            break
                        }
                        count = count + 1
                    }
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openRooms.count
    }
}
