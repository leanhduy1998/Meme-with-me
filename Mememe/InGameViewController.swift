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
    
    var inGameRefObservers = [String:[UInt]]()
    
    
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
    var userImagesDic: [String:UIImage]!
    
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
    
    // addeditmymemeview
    var memeModel: MemeModel!
    var memesArrangement = [String]()
    var myTopText = ""
    var myBottomText = ""
    var memesRelatedPos = [String:String]()
    
    // show picture detail
    var topTextSegue: String!
    var bottomTextSegue: String!
    var imageSegue: UIImage!
    var detailPictureSegueSent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMemes()
        
        setupUI()

        if leaderId == MyPlayerData.id {
            self.createBeginingData()
        }
        else {
            getBeginingGameFromFirB(completionHandler: { () in
                DispatchQueue.main.async {                    
                    self.reloadCurrentPlayersIcon()
                    self.reloadPreviewCards()
                    
                    self.addObserverForCardNormals()
                    self.checkIfYourAreJudge()
                    
                    self.chatHelper.id = self.game.gameId
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
    
    func setupMemes(){
        self.memeModel = MemeHelper.get9Memes()
        self.memesArrangement.append(contentsOf: self.memeModel.topMemes)
        self.memesArrangement.append(contentsOf: self.memeModel.bottomMemes)
        self.memesArrangement.append(contentsOf: self.memeModel.fullMemes)
        self.memesArrangement.shuffle()
        
        for meme in self.memeModel.topMemes {
            self.memesRelatedPos[meme] = "top"
        }
        for meme in self.memeModel.bottomMemes {
            self.memesRelatedPos[meme] = "bot"
        }
        for meme in self.memeModel.fullMemes {
            self.memesRelatedPos[meme] = "full"
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailPictureSegueSent = false
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
                        AvailableRoomHelper.deleteMyAvailableRoom(completeHandler: {})
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
        roomOptionAlertController.addAction(UIAlertAction(title: "Help", style: UIAlertActionStyle.default, handler: help))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)
    }
    
    func help(action: UIAlertAction){
        DisplayAlert.display(controller: self, title: "", message: "Double tap on memes(not yours or empty) to like it. Tap and hold on a meme to view it in detail!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        if let destination = segue.destination as? AddEditMyMemeViewController {
            destination.myPlayerId = MyPlayerData.id
            destination.memeImage = thisRoundImage
            destination.game = game
            destination.leaderId = leaderId
            destination.memeModel = memeModel
            destination.memesArrangement = memesArrangement
            destination.backgroundImage = floorBackground.image
        }
        else if let destination = segue.destination as? JudgingViewController {
            destination.backgroundImage = floorBackground.image
            destination.game = game
            destination.playerJudging = playerJudging
            destination.memeImage = thisRoundImage
            destination.leaderId = leaderId
        }
        else if let destination = segue.destination as? AvailableGamesViewController{
            destination.updateOpenRoomValue()
            backgroundPlayer.stop()
        }
        else if let destination = segue.destination as? PictureDetailViewController{
            destination.topText = topTextSegue
            destination.bottomText = bottomTextSegue
            destination.image = thisRoundImage
        }
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
