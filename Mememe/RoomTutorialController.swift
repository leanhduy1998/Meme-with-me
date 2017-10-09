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

class RoomTutorialController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var startBtn: UIBarButtonItem!
    @IBOutlet weak var emptyChatLabel: UILabel!
    @IBOutlet weak var backgroundIV: UIImageView!
    
    
    var userInRoom = [PlayerData]()
    
    var userImages = [String:UIImage]()
    
    let helper = UserFilesHelper()
    
    var backgroundPlayer:AVAudioPlayer!
    var chatSoundPlayer:AVAudioPlayer!
    
    var messages = [ChatModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        emptyChatLabel.layer.masksToBounds = true
        emptyChatLabel.layer.cornerRadius = 5
        emptyChatLabel.backgroundColor = UIColor.white
        
        let random = Int(arc4random_uniform(2))
        if(random == 0){
            backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "privateRoomMusic", loop: true)
        }
        else{
            backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "privateRoomMusic2", loop: true)
        }
        chatSoundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "messagereceived", loop: false)
        
        tableview.allowsSelection = false
        chatTableView.allowsSelection = false
        
        userInRoom.append(PlayerData(_userId: MyPlayerData.id, _userName: MyPlayerData.name))
        userInRoom.append(PlayerData(_userId: "b1", _userName: "Bot1"))
        userInRoom.append(PlayerData(_userId: "b2", _userName: "Bot2"))
        
        
        
        messages.append(ChatModel(senderId: "b1", senderName: "Bot1", text: "Two bots have joined your room!"))
        chatTableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.messages.append(ChatModel(senderId: "b1", senderName: "Bot1", text: "You can send and receive message here."))
            self.chatTableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.messages.append(ChatModel(senderId: "b1", senderName: "Bot1", text: "The table on top shows how many users are in your room."))
                self.chatTableView.reloadData()
            }
        }
    }
    
    func setBackground(){
        backgroundIV.backgroundColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
        tableview.backgroundColor = UIColor.clear
        chatTableView.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        if(messages.count > 0){
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        backgroundPlayer.play()
    }
    
    @IBAction func startGameBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "InGameViewControllerSegue", sender: self)
    }
    @IBAction func leaveRoomBtnPressed(_ sender: Any) {        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chatSendBtnPressed(_ sender: Any) {
        messages.append(ChatModel(senderId: MyPlayerData.id, senderName: MyPlayerData.name, text: chatTextField.text!))
        chatTextField.text = ""
        chatTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        backgroundPlayer.stop()
        if let destination = segue.destination as?  InGameViewController{
            destination.playersInGame = userInRoom
            destination.leaderId = MyPlayerData.id
        }

    }
    
}

