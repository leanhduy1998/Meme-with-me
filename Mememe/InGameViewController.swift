//
//  InGameViewController.swift
//  Mememe
//
//  Created by Duy Le on 7/31/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import AVFoundation

import FirebaseDatabase

class InGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var AddEditJudgeMemeBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var floorBackground: UIImageView!
    
    @IBOutlet weak var chatSendBtn: UIButton!
    
    var inGameRefObservers = [UInt]()
    
    
    @IBAction func unwindToInGameViewController(segue:UIStoryboardSegue) { }
    //ui
    var screenWidth : CGFloat!
    var screenHeight : CGFloat!
    var space : CGFloat!
    var cardWidth : CGFloat!
    var cardHeight: CGFloat!
    var iconSize: CGFloat!
    var previewScrollHeight : CGFloat!
    var chatViewHeight : CGFloat!
    var currentPlayerScrollHeight : CGFloat!
    
    //controller
    var thisRoundImage: UIImage!
    var playerJudging: String!
    var playersInGame = [PlayerData]()
    var leaderId = ""
    var borderForUserIconIV = UIImageView()
    var game : Game!
    var myCardInserted = false
    var userWhoWon = ""
    
    //preview scroll
    var cardDictionary = [String : CardView]()
    var cardOrder = [String]()
    
    //database
    let inGameRef = Database.database().reference().child("inGame")
    let convertor = InGameHelperConversion()
    var gameDBModel = MememeDBObjectModel()
    
    
    //chat
    let chatHelper = ChatHelper()
    let s3Helper = UserFilesHelper()
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    // conditions for leaving room
    var nextRoundStarting = false
    var currentRoundFinished = false
    var leftRoom = false
    
    //sound player
    var backgroundPlayer:AVAudioPlayer!
    var effectPlayer:AVAudioPlayer!
    
    // animation
    var cardInitialYBeforeAnimation: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if leaderId == MyPlayerData.id {
            self.createBeginingData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                AvailableRoomHelper.makeMyRoomStatusClosed()
            })
        }
        else {
            InGameHelper.getBeginingGameFromFirB(leaderId: leaderId, completionHandler: { (game, leaderId, judgingId) in
                DispatchQueue.main.async {
                    self.playerJudging = judgingId
                    self.leaderId = leaderId
                    self.game = game
                    
                    
                    self.reloadCurrentPlayersIcon()
                    self.reloadPreviewCards()
     
                    self.addObserverForCardNormals()
                    self.checkIfYourAreJudge()
                    
                    self.chatHelper.id = game.gameId
                    self.chatHelper.initializeChatObserver(controller: self)
                    
                    MememeDynamoDB.insertGameWithCompletionHandler(game: self.game, { (gameModel, error) in
                        if error != nil {
                            print(error)
                        }
                        DispatchQueue.main.async {
                            self.gameDBModel = gameModel
                        }
                    })
                }
            })
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if game != nil {
            reloadPreviewCards()
        }
        subscribeToKeyboardNotifications()
        playBackground()
    }
    
    
    var playerJoinedFirebaseCount = 0
    
    func addObserverForCardNormals(){
        if(MyPlayerData.id == leaderId){
            inGameRef.child(game.gameId!).child("players").observe(DataEventType.childAdded, with: { (snapshot) in
                DispatchQueue.main.async {
                    self.playerJoinedFirebaseCount = self.playerJoinedFirebaseCount + 1
                    if(self.playerJoinedFirebaseCount == self.playersInGame.count){
                        AvailableRoomHelper.deleteMyAvailableRoom()
                    }
                }
            })
        }
        
        addPlayerRemovedObserver()
        addNormalCardsAddedObserver()
        addNormalCardsChangedObserver()
        addNormalCardsDeletedObserver()
        addOtherGameDataChangedObserver()
    }
  
    @IBAction func AddEditJudgeMemeBtnPressed(_ sender: Any) {
        if(AddEditJudgeMemeBtn.title == "Add Your Meme!" || AddEditJudgeMemeBtn.title == "Edit Your Meme"){
            performSegue(withIdentifier: "AddEditMyMemeViewController", sender: self)
        }
        else if(AddEditJudgeMemeBtn.title == "Judge Your People!"){
            inGameRef.child(game.gameId!).child("normalCards").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let postDict = snapshot.value as? [String : [String:Any]]
                
                DispatchQueue.main.async {
                    if postDict?.count == self.playersInGame.count - 1 {
                        self.performSegue(withIdentifier: "JudgingViewControllerSegue", sender: self)
                    }
                    else{
                        self.AddEditJudgeMemeBtn.isEnabled = false
                    }
                }
            })
            
        }
        else if(AddEditJudgeMemeBtn.title == "Start Next Round!"){
            inGameRef.child(game.gameId!).child("nextRoundStarting").setValue("true")
        }
    }
    
    @IBAction func optionBtnPressed(_ sender: Any) {
        let roomOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        roomOptionAlertController.addAction(UIAlertAction(title: "Leave Room", style: UIAlertActionStyle.default, handler: leaveRoom))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        if let destination = segue.destination as? AddEditMyMemeViewController {
            destination.myPlayerId = MyPlayerData.id
            destination.memeImage = thisRoundImage
            destination.game = game
            destination.leaderId = leaderId
        }
        else if let destination = segue.destination as? JudgingViewController {
            destination.game = game
            destination.playerJudging = playerJudging
            destination.memeImage = thisRoundImage
            destination.leaderId = leaderId
        }
        else if let destination = segue.destination as? AvailableGamesViewController{
            destination.updateOpenRoomValue()
        }
    }
}
