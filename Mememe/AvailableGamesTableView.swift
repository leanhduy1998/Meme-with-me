//
//  AvailableGamesTableView.swift
//  Mememe
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
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.activityIndicator.startAnimating()
            
            for (playerId,_) in room.playerInRoom! {
                self.helper.loadUserProfilePicture(userId: (playerId), completeHandler: { (imageData) in
                    DispatchQueue.main.async{
                        let image = UIImage(data: imageData)
                        if cell.imageview.image != image {
                            cell.imageview.image = image
                            cell.activityIndicator.stopAnimating()
                        }
                    }
                })
                cell.imageview = CircleImageCutter.roundImageView(imageview: cell.imageview, radius: 15)
                return cell
            }
        }
        else if (room.playerInRoom?.count)! == 2 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesTwoImageCell") as? AvailableGamesTwoImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.activityIndicator.startAnimating()
            
            var playerImages = [UIImage]()
            
            for (playerId,_) in room.playerInRoom! {
                helper.loadUserProfilePicture(userId: playerId, completeHandler: { (imageData) in
                    DispatchQueue.main.async{
                        var image = UIImage(data: imageData)
                        playerImages.append(image!)
                        
                        if playerImages.count == 2 {
                            cell.firstIV.image = playerImages[0]
                            cell.secondIV.image = playerImages[1]
                            cell.activityIndicator.stopAnimating()
                            cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 15)
                            cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 15)
                        }
                    }
                })
            }
            return cell
        }
        else if (room.playerInRoom?.count)! == 3 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesThreeImageCell") as? AvailableGamesThreeImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.activityIndicator.startAnimating()
            
            var playerImages = [UIImage]()
            
            for (playerId,_) in room.playerInRoom! {
                helper.loadUserProfilePicture(userId: playerId, completeHandler: { (imageData) in
                    DispatchQueue.main.async{
                        var image = UIImage(data: imageData)
                        playerImages.append(image!)
                        
                        if playerImages.count == 3 {
                            cell.firstIV.image = playerImages[0]
                            cell.secondIV.image = playerImages[1]
                            cell.thirdIV.image = playerImages[2]
                            cell.activityIndicator.stopAnimating()
                            cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 15)
                            cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 15)
                            cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 15)
                        }
                    }
                })
            }
            return cell
        }
        else if (room.playerInRoom?.count)! >= 4 {
            
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesFourImageCell") as? AvailableGamesFourImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.nameLabel.text = getLeaderNameFromRoom(room: room)
            
            cell.nameLabel.layer.masksToBounds = true
            cell.nameLabel.layer.cornerRadius = 5
            
            cell.activityIndicator.startAnimating()
            
            var playerImages = [UIImage]()
            
            for (playerId,_) in room.playerInRoom! {
                helper.loadUserProfilePicture(userId: playerId, completeHandler: { (imageData) in
                    DispatchQueue.main.async{
                        var image = UIImage(data: imageData)
                        playerImages.append(image!)
                        
                        if playerImages.count == 3 {
                            cell.firstIV.image = playerImages[0]
                            cell.secondIV.image = playerImages[1]
                            cell.thirdIV.image = playerImages[2]
                            cell.fourthIV.image = playerImages[3]
                            cell.activityIndicator.stopAnimating()
                            cell.firstIV = CircleImageCutter.roundImageView(imageview: cell.firstIV, radius: 15)
                            cell.secondIV = CircleImageCutter.roundImageView(imageview: cell.secondIV, radius: 15)
                            cell.thirdIV = CircleImageCutter.roundImageView(imageview: cell.thirdIV, radius: 15)
                            cell.fourthIV = CircleImageCutter.roundImageView(imageview: cell.fourthIV, radius: 15)
                        }
                    }
                })
            }
            
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
                        
                        self.plusBtnView.isHidden = true
                        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.none
                        self.availableRoomRef.removeAllObservers()
                        
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
                                }
                            }
                        })
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
