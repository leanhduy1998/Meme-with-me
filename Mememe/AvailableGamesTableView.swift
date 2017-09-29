//
//  AvailableGamesTableView.swift
//  Mememe
//
//  Created by Duy Le on 9/17/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension AvailableGamesViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let room = openRooms[indexPath.row]
        
        if room.roomImageUrl! == "noURL" && (room.playerInRoom?.count)! > 1 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesNoImageCell") as? AvailableGamesNoImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.nameLabel.text = getNamefromAllPlayerInRoom(playerArr: room.playerInRoom!)
            cell.activityIndicator.startAnimating()
            
            var playerImages = [UIImage]()
            
            
            for (playerId,_) in room.playerInRoom! {
                
                helper.loadUserProfilePicture(userId: playerId, completeHandler: { (imageData) in
                    DispatchQueue.main.async{
                        var image = UIImage(data: imageData)
                        
                        var newImage:UIImage;
                        
                        // Decompress the image into a bitmap
                        
                        let size = CGSize(width: cell.topLeftIV.frame.width, height: cell.topLeftIV.frame.height)
                        UIGraphicsBeginImageContextWithOptions(size, true, 0);
                        image?.draw(in: CGRect(x:0,y:0,width:size.width, height:size.height))
                        newImage = UIGraphicsGetImageFromCurrentImageContext()!;
                        UIGraphicsEndImageContext();
                        
                        
                        image = newImage
                        
                        playerImages.append(image!)
                        
                        switch(playerImages.count){
                        case 1:
                            cell.topLeftIV.image = playerImages[0]
                            break
                        case 2:
                            cell.topLeftIV.image = playerImages[0]
                            cell.topRightIV.image = playerImages[1]
                            break
                        case 3:
                            cell.topLeftIV.image = playerImages[0]
                            cell.topRightIV.image = playerImages[1]
                            cell.bottomLeftIV.image = playerImages[2]
                            break
                        case 4:
                            cell.topLeftIV.image = playerImages[0]
                            cell.topRightIV.image = playerImages[1]
                            cell.bottomLeftIV.image = playerImages[2]
                            cell.bottomRightIV.image = playerImages[3]
                            break
                        default:
                            break
                        }
                        
                        cell.activityIndicator.stopAnimating()
                    }
                })
            }
            return cell
        }
        else if room.roomImageUrl! == "noURL" && (room.playerInRoom?.count)! == 1 {
            var cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesExistImageCell") as? AvailableGamesExistImageCell)!
            cell = CellAnimator.add(cell: cell)
            cell.nameLabel.text = getNamefromAllPlayerInRoom(playerArr: room.playerInRoom!)
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
                return cell
            }
        }
        /*
        else if room.roomImageUrl! == "noURL" {
            let cell = (tableView.dequeueReusableCell(withIdentifier: "AvailableGamesExistImageCell") as? AvailableGamesExistImageCell)!
            cell.nameLabel.text = getNamefromAllPlayerInRoom(playerArr: room.playerInRoom!)
            cell.activityIndicator.startAnimating()
            
            
            print("not configer yet")
            //remember to
            cell.activityIndicator.stopAnimating()
    
            return cell
        }*/
        else {
            DisplayAlert.display(controller: self, title: "Error loading Available Games Table View Cell", message: "")
            return UITableViewCell()
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserOnlineSystem.getUserOnlineStatus(userId: openRooms[indexPath.row].leaderId!) { (isLeaderOnline) in
            DispatchQueue.main.async {
                if isLeaderOnline {
                    if self.openRooms[indexPath.row].roomIsOpen == "true"{
                        self.selectedLeaderId = self.openRooms[indexPath.row].leaderId
                        
                        UIView.animate(withDuration: 1, animations: {
                            tableView.backgroundColor = UIColor.black
                            tableView.visibleCells[indexPath.row].frame.origin.x = self.view.frame.midX 
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
                        self.tableview.reloadData()
                    }
                }
                else {
                    var count = 0
                    for r in self.openRooms {
                        if r.leaderId == self.openRooms[indexPath.row].leaderId {
                            self.openRooms.remove(at: count)
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
