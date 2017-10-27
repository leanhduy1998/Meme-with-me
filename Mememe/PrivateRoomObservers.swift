//
//  PrivateRoomObservers.swift
//  Mememe
//
//  Created by Duy Le on 10/25/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import Firebase
import SwiftTryCatch

extension PrivateRoomViewController{
    func addPlayerInRoomAddedObserver(){
        let ob2 = availableRoomRef.child(leaderId).child("playerInRoom").observe(DataEventType.childAdded, with: { (snapshot) in
            DispatchQueue.main.async {
                if(self.availableRoomObservers["\(self.leaderId!)/playerInRoom"] == nil){
                    return
                }
                
                let playerName = snapshot.value as? String
                let playerId = snapshot.key
                
                
                var exist = false
                for r in self.userInRoom {
                    if r.userId == playerId {
                        exist = true
                    }
                }
                
                self.startBtn.isEnabled = false
                self.startBtnPlayerAddedDebt = self.startBtnPlayerAddedDebt + 1
                
                if !exist {
                    let newData = PlayerData(_userId: playerId, _userName: playerName!)
                    self.userInRoom.append(newData)
                    self.helper.loadUserProfilePicture(userId: playerId) { (imageData) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            self.userImagesDic[playerId] = image
                            
                            if(self.userImagesDic.count == self.userInRoom.count && self.userInRoom.count > 1){
                                self.checkIfStartBtnCanBeEnabled()
                            }
                            
                            SwiftTryCatch.try({
                                self.tableview.insertRows(at: [IndexPath(row: self.userInRoom.count-1, section: 0)], with: UITableViewRowAnimation.left)
                            }, catch: { (error) in
                                self.tableview.reloadData()
                            }, finally: {
                                // close resources
                            })
                        }
                    }
                    
                }
            }
        })
        if availableRoomObservers["\(leaderId!)/playerInRoom"] == nil {
            availableRoomObservers["\(leaderId!)/playerInRoom"] = []
        }
        availableRoomObservers["\(leaderId!)/playerInRoom"]!.append(ob2)
    }
    func checkIfStartBtnCanBeEnabled(){
        if(!self.startBtnTimerIsCounting){
            self.startBtnTimerIsCounting = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.startBtnPlayerAddedDebt = self.startBtnPlayerAddedDebt - 1
                self.startBtnTimerIsCounting = false
                
                if(self.startBtnPlayerAddedDebt == 0){
                    self.startBtn.isEnabled = true
                }
                else{
                    self.checkIfStartBtnCanBeEnabled()
                }
            })
        }
        else{
            self.startBtn.isEnabled = false
        }
    }
    
    
    
    func addPlayerInRoomRemovedObserver(){
        let ob3 = availableRoomRef.child(leaderId).child("playerInRoom").observe(DataEventType.childRemoved, with: { (snapshot) in
            DispatchQueue.main.async {
                if(self.availableRoomObservers["\(self.leaderId!)/playerInRoom"] == nil){
                    return
                }
                
                let value = snapshot.value as? String
                let postDict = [snapshot.key:value]
                
                for (playerId,_) in postDict {
                    if playerId == MyPlayerData.id {
                        self.kickedOut = true
                        self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
                    }
                    
                    var count = 0
                    for user in self.userInRoom {
                        if user.userId == playerId {
                            self.userInRoom.remove(at: count)
                            
                            SwiftTryCatch.try({
                                self.tableview.deleteRows(at: [IndexPath(row: count, section: 0)], with: UITableViewRowAnimation.right)
                            }, catch: { (error) in
                                self.tableview.reloadData()
                            }, finally: {
                                // close resources
                            })
                            
                            self.userImagesDic.removeValue(forKey: playerId)
                            break
                        }
                        count = count + 1
                    }
                }
                if self.userInRoom.count == 1 {
                    self.startBtn.isEnabled = false
                }
            }
        })
        if availableRoomObservers["\(leaderId!)/playerInRoom"] == nil {
            availableRoomObservers["\(leaderId!)/playerInRoom"] = []
        }
        availableRoomObservers["\(leaderId!)/playerInRoom"]!.append(ob3)
    }
    
    func addInGameObservers(){
        // if game has been created, go to another segue
        let ob4 = inGameRef.observe(DataEventType.childAdded, with: { (snapshot) in
            if snapshot.key.contains(self.leaderId)  && self.leaderId != MyPlayerData.id {
                DispatchQueue.main.async {
                    if !self.segueAlreadyPushed{
                        self.segueAlreadyPushed = true
                        self.performSegue(withIdentifier: "InGameViewControllerSegue", sender: self)
                    }
                    
                }
            }
        })
        inGameObservers.append(ob4)
    }
    func addIfTheRoomIAmInIsRemovedObserver(){
        // if main room got removed
        let ob1 = availableRoomRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            if snapshot.key == self.leaderId && self.leaderId != MyPlayerData.id {
                DispatchQueue.main.async {
                    if !self.segueAlreadyPushed{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        })
        if availableRoomObservers[""] == nil {
            availableRoomObservers[""] = []
        }
        availableRoomObservers[""] = [ob1]
    }
    func removeAllObservers(){
        for x in inGameObservers {
            inGameRef.removeObserver(withHandle: x)
        }
        for (directory,observers) in availableRoomObservers{
            if directory == ""{
                for ob in observers {
                    availableRoomRef.removeObserver(withHandle: ob)
                }
            }
            else{
                for ob in observers {
                    availableRoomRef.child(directory).removeObserver(withHandle: ob)
                }
            }
        }
        availableRoomObservers.removeAll()
        inGameObservers.removeAll()
        chatHelper.removeChatObserver()
    }
}
