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
    let availableRoomRef = Database.database().reference().child("availableRoom")
    let inGameRef = Database.database().reference().child("inGame")
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
    var userImagesDic = [String:UIImage]()
    
    var leaderId: String!
    
    
    let helper = UserFilesHelper()
    
    var backgroundPlayer:AVAudioPlayer!
    var chatSoundPlayer:AVAudioPlayer!
    
    // startBtnTimer
    var startBtnTimerIsCounting = false
    
    var availableRoomObservers = [String:[UInt]]()
    var inGameObservers = [UInt]()
    
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
        let ob1 = availableRoomRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            if snapshot.key == self.leaderId && self.leaderId != MyPlayerData.id {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
        if availableRoomObservers[""] == nil {
            availableRoomObservers[""] = []
        }
        availableRoomObservers[""] = [ob1]
        
        // if there is no leader, the user created this room will be leader
        if leaderId == nil || leaderId == MyPlayerData.id {
            leaderId = AWSIdentityManager.default().identityId!
            chatHelper.removeChatRoom(id: MyPlayerData.id)
            startBtn.isEnabled = false
            
            AvailableRoomHelper.uploadEmptyRoomToFirB(leaderId: MyPlayerData.id, roomType: "private")
            
            let playerData = PlayerData(_userId: MyPlayerData.id, _userName: MyPlayerData.name)
            
            self.userInRoom.append(playerData)
           // self.tableview.insertRows(at: [IndexPath(row: self.userInRoom.count-1, section: 0)], with: UITableViewRowAnimation.left)
            self.tableview.reloadData()
            self.userImagesDic[MyPlayerData.id] = UIImage()
            
            self.helper.loadUserProfilePicture(userId: MyPlayerData.id) { (imageData) in
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                                        
                    self.userImagesDic[MyPlayerData.id] = image
                    self.tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.left)
                    //self.tableview.reloadData()
                    
                    self.addPlayerInRoomAddedObserver()
                    self.addPlayerInRoomRemovedObserver()
                    self.addInGameObservers()
                }
            }
        }
        else {
            AvailableRoomHelper.insertYourselfIntoSomeoneRoom(leaderId: leaderId)
            availableRoomRef.child(leaderId).child("playerInRoom").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
               /* if(self.availableRoomObservers["\(self.leaderId!)/playerInRoom"] == nil){
                    return
                }*/
                
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
                                //self.tableview.reloadData()
                            }
                        }
                        self.addPlayerInRoomAddedObserver()
                        self.addPlayerInRoomRemovedObserver()
                        self.addInGameObservers()
                    }
                }
            })
            startBtn.title = ""
            startBtn.isEnabled = false
        }
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
        removeAllObservers()
        chatHelper.removeChatRoom(id: leaderId)
        
        backgroundPlayer.stop()
        
        if leaderId == MyPlayerData.id {
            AvailableRoomHelper.deleteMyAvailableRoom {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        else {
            AvailableRoomHelper.removeYourselfIntoSomeoneRoom(leaderId: leaderId, completeHandler: {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
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
        if(backgroundPlayer != nil){
            backgroundPlayer.stop()
            backgroundPlayer = nil
        }
        
        if let destination = segue.destination as? InGameViewController {
            removeAllObservers()
            destination.playersInGame = userInRoom
            destination.leaderId = leaderId
            destination.userImagesDic = userImagesDic
        }
        else if let destination = segue.destination as? AvailableGamesViewController{
            removeAllObservers()
            destination.selectedLeaderId = nil
            destination.getRoomDataFromDB()
            leaderId = nil
        }
    }

}
