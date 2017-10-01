//
//  PrivateRoomViewController.swift
//  Mememe
//
//  Created by Duy Le on 7/31/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import FirebaseDatabase

class PrivateRoomViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private let availableRoomRef = Database.database().reference().child("availableRoom")
    private let inGameRef = Database.database().reference().child("inGame")
    let chatRef = Database.database().reference().child("chat")
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var startBtn: UIBarButtonItem!
    
    let chatHelper = ChatHelper()
    
    var userInRoom = [PlayerData]()
    var leaderId: String!
    
    var userImages = [String:UIImage]()
    
    
    
    let helper = UserFilesHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        if(leaderId == nil){
             chatHelper.id = MyPlayerData.id
        }
        else {
            chatHelper.id = leaderId
        }
       
        chatHelper.initializeChatObserver(controller: self)
        
        
        // if main room got removed
        availableRoomRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            if snapshot.key == self.leaderId && self.leaderId != MyPlayerData.id {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
        
        // if there is no leader, the user created this room will be leader
        if leaderId == nil || leaderId == AWSIdentityManager.default().identityId! {
            leaderId = AWSIdentityManager.default().identityId!
            chatHelper.removeYourChatRoom()
            startBtn.isEnabled = false
            
            AvailableRoomHelper.uploadEmptyRoomToFirB(leaderId: MyPlayerData.id, roomType: "private")
            
            let playerData = PlayerData(_userId: MyPlayerData.id, _userName: MyPlayerData.name)
            userInRoom.append(playerData)
            tableview.reloadData()
        }
        else {
            AvailableRoomHelper.insertYourselfIntoSomeoneRoom(leaderId: leaderId)
            availableRoomRef.child(leaderId).child("playerInRoom").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String:String]
                if postDict != nil {
                    for (playerId,playerName) in postDict! {
                        var exist = false
                        for r in self.userInRoom {
                            if r.userId == playerId {
                                exist = true
                            }
                        }
                        if !exist {
                            let newData = PlayerData(_userId: playerId, _userName: playerName)
                            self.userInRoom.append(newData)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                }
            })
            startBtn.title = ""
            startBtn.isEnabled = false
        }
        availableRoomRef.child(leaderId).child("playerInRoom").observe(DataEventType.childAdded, with: { (snapshot) in
            let value = snapshot.value as? String
            let postDict = [snapshot.key:value]
            
            for (playerId,playerName) in postDict {
                var exist = false
                for r in self.userInRoom {
                    if r.userId == playerId {
                        exist = true
                    }
                }
                if !exist {
                    let newData = PlayerData(_userId: playerId, _userName: playerName!)
                    self.userInRoom.append(newData)
                }
            }
            DispatchQueue.main.async {
                if self.userInRoom.count > 1 {
                    self.startBtn.isEnabled = true
                }
                self.tableview.reloadData()
            }
        })
        
        
        availableRoomRef.child(leaderId).child("playerInRoom").observe(DataEventType.childRemoved, with: { (snapshot) in
            let value = snapshot.value as? String
            let postDict = [snapshot.key:value]
            
            for (playerId,_) in postDict {
                var count = 0
                for user in self.userInRoom {
                    if user.userId == playerId {
                        self.userInRoom.remove(at: count)
                        break
                    }
                    count = count + 1
                }
            }
            DispatchQueue.main.async {
                if self.userInRoom.count == 1 {
                    self.startBtn.isEnabled = false
                }
                self.tableview.reloadData()
            }
        })
        // if game has been created, go to another segue
        inGameRef.observe(DataEventType.childAdded, with: { (snapshot) in
            if snapshot.key.contains(self.leaderId)  && self.leaderId != MyPlayerData.id {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "InGameViewControllerSegue", sender: self)
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        if(self.chatHelper.messages.count > 0){
            let indexPath = IndexPath(row: self.chatHelper.messages.count-1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func startGameBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "InGameViewControllerSegue", sender: self)
    }
    @IBAction func leaveRoomBtnPressed(_ sender: Any) {
        if leaderId == MyPlayerData.id {
            AvailableRoomHelper.deleteMyRoom()
        }
        else {
            AvailableRoomHelper.removeYourselfIntoSomeoneRoom(leaderId: leaderId)
        }
        inGameRef.removeAllObservers()
        availableRoomRef.removeAllObservers()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chatSendBtnPressed(_ sender: Any) {
        chatHelper.insertMessage(text: chatTextField.text!)
        chatTextField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        if let destination = segue.destination as? InGameViewController {
            destination.playersInGame = userInRoom
            destination.leaderId = leaderId
            
            inGameRef.removeAllObservers()
            availableRoomRef.removeAllObservers()
            chatHelper.removeChatObserver()
        }
        else if let destination = segue.destination as? AvailableGamesViewController{
            destination.selectedLeaderId = nil
            leaderId = nil
            chatHelper.removeChatObserver()
        }
    }

}
