//
//  AvailableGamesViewController.swift
//  Meme with Me
//
//  Created by Duy Le on 7/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AVFoundation
import FirebaseDatabase
import SwiftTryCatch

class AvailableGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBAction func unwindToAvailableGamesViewController(segue:UIStoryboardSegue) { }
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    var openRooms = [AvailableRoomFirBModel]()
    var selectedLeaderId: String!
    let helper = UserFilesHelper()
    
    let availableRoomRef = Database.database().reference().child("availableRoom")
    
    var backgroundPlayer: AVAudioPlayer!
    var observers = [UInt]()
    
    private let refreshControl = UIRefreshControl()
    
    //segue
    var kickedOutOfRoom = false
    
    override func viewDidLoad() {
        addBtn.layer.masksToBounds = true
        addBtn.layer.cornerRadius = CGFloat(5)
        
        UserOnlineSystem.updateUserOnlineStatus()
        tableview.reloadData()
        
        let random = Int(arc4random_uniform(2))
        if random == 0 {
            backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "availableRoomMusic", loop: true)
        }
        else{
            backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "availableRoomMusic2", loop: true)
        }
        
        
        if #available(iOS 10.0, *) {
            tableview.refreshControl = refreshControl
        } else {
            tableview.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(pulledRefreshedControl(_:)), for: .valueChanged)
    }
    
    func pulledRefreshedControl(_ sender: Any){
        updateOpenRoomValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AvailableRoomHelper.deleteMyAvailableRoom(completeHandler: {
            DispatchQueue.main.async {
                self.getRoomDataFromDB()
                self.updateOpenRoomValue()
            }
        })
        InGameHelper.removeYourInGameRoom()
        
        selectedLeaderId = nil
        setupUI()
        backgroundPlayer.play()
        
        if kickedOutOfRoom {
            kickedOutOfRoom = false
            displayKickedOutAlert()
        }
    }
    
    func getNamefromAllPlayerInRoom(playerArr: [String:Any]) -> String{
        var string = ""
        
        var count = 0
        for (_,value) in playerArr {
            string.append(String(describing: value))
            if count != playerArr.count - 1 {
                string.append(", ")
            }
            count = count + 1
        }
        return string
    }
    func getLeaderNameFromRoom(room: AvailableRoomFirBModel) -> String{
        return "\(room.leaderName!)'s room"
    }
    
    func getRoomDataFromDB(){
        let ob1 = availableRoomRef.observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            let room = AvailableRoomHelper.transferValueFromMapToRoom(leaderId: snapshot.key, map: postDict)
            
            DispatchQueue.main.async {
                UserOnlineSystem.getUserOnlineStatus(userId: room.leaderId!, completionHandler: { (isUserOnline) in
                    DispatchQueue.main.async {
                        self.appendRoomIfRoomIsOpen(isUserOnline: isUserOnline, room: room)
                    }
                })
            }
        })
        observers.append(ob1)
        
        let ob2 = availableRoomRef.observe(DataEventType.childChanged, with: { (snapshot) in
            DispatchQueue.main.async {
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                
                let room = AvailableRoomHelper.transferValueFromMapToRoom(leaderId: snapshot.key, map: postDict)
                
                var count = 0
                for r in self.openRooms {
                    if r.leaderId == room.leaderId {
                        self.openRooms[count] = room
                        break
                    }
                    count = count + 1
                }
                SwiftTryCatch.try({
                    self.tableview.reloadRows(at: [IndexPath(item: count, section: 0)], with: UITableViewRowAnimation.right)
                }, catch: { (error) in
                    self.tableview.reloadData()
                }, finally: {
                    // close resources
                })
            }
        })
        observers.append(ob2)
        
        let ob3 = availableRoomRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            DispatchQueue.main.async {
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                
                let room = AvailableRoomHelper.transferValueFromMapToRoom(leaderId: snapshot.key, map: postDict)
                
                var count = 0
                for r in self.openRooms {
                    if r.leaderId == room.leaderId {
                        self.openRooms.remove(at: count)
                        SwiftTryCatch.try({
                            self.tableview.deleteRows(at: [IndexPath(row: count, section: 0)], with: UITableViewRowAnimation.right)
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
        })
         observers.append(ob3)
    }
    func updateOpenRoomValue(){
        self.openRooms.removeAll()
        self.tableview.reloadData()
        
        availableRoomRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            DispatchQueue.main.async {
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                if postDict.count == 0 {
                    self.refreshControl.endRefreshing()
                }
                
                for(leaderId,value) in postDict {
                    let room = AvailableRoomHelper.transferValueFromMapToRoom(leaderId: leaderId, map: value as! [String : AnyObject])
                    
                    UserOnlineSystem.getUserOnlineStatus(userId: room.leaderId!, completionHandler: { (isUserOnline) in
                        DispatchQueue.main.async {
                            self.appendRoomIfRoomIsOpen(isUserOnline: isUserOnline, room: room)
                            self.refreshControl.endRefreshing()
                        }
                    })
                }
            }
        })
    }
    
    func appendRoomIfRoomIsOpen(isUserOnline: Bool, room: AvailableRoomFirBModel){
        if isUserOnline{
            var exist = false
            for r in openRooms {
                if r.leaderId == room.leaderId {
                    exist = true
                    break
                }
                if r.roomIsOpen == "false" {
                    exist = true
                }
            }
            if exist == false {
                openRooms.append(room)
                SwiftTryCatch.try({
                    self.tableview.insertRows(at: [IndexPath(row: self.openRooms.count-1, section: 0)], with: UITableViewRowAnimation.left)
                }, catch: { (error) in
                    self.tableview.reloadData()
                }, finally: {
                    // close resources
                })
                
            }
        }
    }
    
    func removeAllObservers(){
        var x = 0
        for ob in observers{
            availableRoomRef.removeObserver(withHandle: ob)
            x=x+1
        }
        observers.removeAll()
    }
    
    func displayKickedOutAlert(){
        DisplayAlert.display(controller: self, title: "You are meant for greater things!", message: "You got kicked out :(")
    }
    
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        /*
        let roomOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        roomOptionAlertController.addAction(UIAlertAction(title: "Create/Join a random game", style: UIAlertActionStyle.default, handler: createARandomGame))
        roomOptionAlertController.addAction(UIAlertAction(title: "Create an open mixed game", style: UIAlertActionStyle.default, handler: createAMixedGame))
        roomOptionAlertController.addAction(UIAlertAction(title: "Create a room", style: UIAlertActionStyle.default, handler: createAPrivateGame))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)*/
        performSegue(withIdentifier: "PrivateRoomViewControllerSegue", sender: self)
    }
    
    func createARandomGame(action: UIAlertAction){
        
    }
    func createAMixedGame(action: UIAlertAction){
        
    }
    func createAPrivateGame(action: UIAlertAction){
        performSegue(withIdentifier: "PrivateRoomViewControllerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        backgroundPlayer.stop()
        if let destination = segue.destination as? PrivateRoomViewController {
            availableRoomRef.removeAllObservers()
            destination.leaderId = selectedLeaderId
        }
    }
    

}
