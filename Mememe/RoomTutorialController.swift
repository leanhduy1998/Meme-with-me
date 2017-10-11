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
    
    @IBOutlet weak var leaveRoomBtn: UIBarButtonItem!
    
    
    var userInRoom = [PlayerData]()
    
    var userImages = [String:UIImage]()
    
    let helper = UserFilesHelper()
    
    var backgroundPlayer:AVAudioPlayer!
    var chatSoundPlayer:AVAudioPlayer!
    
    var messages = [ChatModel]()
    
    var alertController = UIAlertController()
    
    //step 3: leave room and come back
    var step4IsReady = false
    
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
        
        
        userInRoom.append(PlayerData(_userId: "b1", _userName: "Bot1"))
        userInRoom.append(PlayerData(_userId: MyPlayerData.id, _userName: MyPlayerData.name))
        userInRoom.append(PlayerData(_userId: "b2", _userName: "Bot2"))
        
        chatTextField.isEnabled = false
        
        messages.append(ChatModel(senderId: "b1", senderName: "Bot1", text: "Hi!"))
        chatTableView.reloadData()
        
        startBtn.isEnabled = false
        leaveRoomBtn.isEnabled = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isBeingPresented || self.isMovingToParentViewController {
            if(!step4IsReady){
                alertController = UIAlertController(title: "You can send and receive message here.", message: "Try to say Hi to your bots!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.default, handler: letUserTakeOver))
                present(alertController, animated: true, completion: nil)
                chatTextField.isEnabled = true
            }
        }
    }
    func letUserTakeOver(action: UIAlertAction){
        startBtn.isEnabled = true
        leaveRoomBtn.isEnabled = true
    }
    
    func step2(){
        chatTextField.isEnabled = false
        for cell in tableview.visibleCells {
            cell.backgroundColor = UIColor.clear
        }
        alertController = UIAlertController(title: "Nice job!", message: "The table on top shows how many users are in your room.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: step3))
        alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.default, handler: letUserTakeOver))
        present(alertController, animated: true, completion: nil)
    }
    func step3(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        alertController = UIAlertController(title: "You can leave the current room using the button on top left!", message: "Try to leave and create another room to continue!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        leaveRoomBtn.isEnabled = true
    }
    func step4(){
        alertController = UIAlertController(title: "You can start the game using the button on top right", message: "Tap it to continue the tutorial!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        startBtn.isEnabled = true
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
        
        if(step4IsReady){
            step4()
        }
    }
    
    @IBAction func chatSendBtnPressed(_ sender: Any) {
        if(chatTextField.text == "" || chatTextField.text == nil){
            return
        }
        messages.append(ChatModel(senderId: MyPlayerData.id, senderName: MyPlayerData.name, text: chatTextField.text!))
        chatTextField.text = ""
        chatTableView.reloadData()
        
        step2()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        backgroundPlayer.stop()
        if let destination = segue.destination as?  InGameTutController{
            destination.playersInGame = userInRoom
            destination.leaderId = MyPlayerData.id
            destination.playersInGame = userInRoom
        }
        if let destination = segue.destination as?  AvailableGameTutorialController{
            destination.step3OfRoomTut = true
        }
        

    }
    
}

