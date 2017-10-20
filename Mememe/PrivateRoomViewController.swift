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
import AVFoundation

class PrivateRoomViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private let availableRoomRef = Database.database().reference().child("availableRoom")
    private let inGameRef = Database.database().reference().child("inGame")
    let chatRef = Database.database().reference().child("chat")
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var startBtn: UIBarButtonItem!
    @IBOutlet weak var emptyChatLabel: UILabel!
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var chatSendBtn: UIButton!
    
    
    let chatHelper = ChatHelper()
    
    var userInRoom = [PlayerData]()
    var userImagesDic = [String:Data]()
    
    var leaderId: String!
    
    
    let helper = UserFilesHelper()
    
    var backgroundPlayer:AVAudioPlayer!
    var chatSoundPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMusic()
        
        InGameHelper.removeYourInGameRoom()
        
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
            chatHelper.removeChatRoom(id: MyPlayerData.id)
            startBtn.isEnabled = false
            
            AvailableRoomHelper.uploadEmptyRoomToFirB(leaderId: MyPlayerData.id, roomType: "private")
            
            let playerData = PlayerData(_userId: MyPlayerData.id, _userName: MyPlayerData.name)
            userInRoom.append(playerData)
            tableview.insertRows(at: [IndexPath(row: userInRoom.count-1, section: 0)], with: UITableViewRowAnimation.left)
        }
        else {
            AvailableRoomHelper.insertYourselfIntoSomeoneRoom(leaderId: leaderId)
            availableRoomRef.child(leaderId).child("playerInRoom").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String:String]
                if postDict != nil {
                    DispatchQueue.main.async {
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
                                self.tableview.insertRows(at: [IndexPath(row: self.userInRoom.count-1, section: 0)], with: UITableViewRowAnimation.left)
                            }
                        }
                    }
                }
            })
            startBtn.title = ""
            startBtn.isEnabled = false
        }
        availableRoomRef.child(leaderId).child("playerInRoom").observe(DataEventType.childAdded, with: { (snapshot) in
            DispatchQueue.main.async {
                let playerName = snapshot.value as? String
                let playerId = snapshot.key
                
         
                var exist = false
                for r in self.userInRoom {
                    if r.userId == playerId {
                        exist = true
                    }
                }
                if !exist {
                    let newData = PlayerData(_userId: playerId, _userName: playerName!)
                    self.userInRoom.append(newData)
                    self.tableview.insertRows(at: [IndexPath(row: self.userInRoom.count-1, section: 0)], with: UITableViewRowAnimation.left)
                }
            
                self.startBtn.isEnabled = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    if self.userInRoom.count > 1 {
                        self.startBtn.isEnabled = true
                    }
                    
                })
            }
        })
        
        availableRoomRef.child(leaderId).child("playerInRoom").observe(DataEventType.childRemoved, with: { (snapshot) in
            DispatchQueue.main.async {
                let value = snapshot.value as? String
                let postDict = [snapshot.key:value]
                
                for (playerId,_) in postDict {
                    var count = 0
                    for user in self.userInRoom {
                        if user.userId == playerId {
                            self.userInRoom.remove(at: count)

                            self.tableview.deleteRows(at: [IndexPath(row: count, section: 0)], with: UITableViewRowAnimation.right)
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
        InGameHelper.removeYourLeaderInGameRoom(leaderId: leaderId)
        InGameHelper.removeYourInGameRoom()
        subscribeToKeyboardNotifications()
        if(self.chatHelper.messages.count > 0){
            let indexPath = IndexPath(row: self.chatHelper.messages.count-1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        if(backgroundPlayer == nil){
            setupMusic()
        }
        backgroundPlayer.play()
    }
    
    @IBAction func startGameBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "InGameViewControllerSegue", sender: self)
    }
    @IBAction func leaveRoomBtnPressed(_ sender: Any) {
        inGameRef.removeAllObservers()
        availableRoomRef.removeAllObservers()
        chatHelper.removeChatRoom(id: leaderId)
        backgroundPlayer.stop()
        
        if leaderId == MyPlayerData.id {
            AvailableRoomHelper.deleteMyAvailableRoom()
        }
        else {
            AvailableRoomHelper.removeYourselfIntoSomeoneRoom(leaderId: leaderId)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chatSendBtnPressed(_ sender: Any) {
        if(chatTextField.text == "" || chatTextField.text == nil){
            return
        }
        chatHelper.insertMessage(text: chatTextField.text!)
        chatTextField.text = ""
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        backgroundPlayer.stop()
        backgroundPlayer = nil
        if let destination = segue.destination as? InGameViewController {
            destination.playersInGame = userInRoom
            destination.leaderId = leaderId
            destination.userImagesDic = userImagesDic
            
            inGameRef.removeAllObservers()
            availableRoomRef.removeAllObservers()
            chatHelper.removeChatObserver()
        }
        else if let destination = segue.destination as? AvailableGamesViewController{
            destination.selectedLeaderId = nil
            destination.getRoomDataFromDB()
            leaderId = nil
            chatHelper.removeChatObserver()
        }
    }

}
