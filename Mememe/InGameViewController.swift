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

import FirebaseDatabase

class InGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var AddEditJudgeMemeBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
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
    var crownUserIconIV = UIImageView()
    var game : Game!
    var myCardInserted = false
    
    //database
    let inGameRef = Database.database().reference().child("inGame")
    private let convertor = InGameHelperConversion()
    
    
    //chat
    let chatHelper = ChatHelper()
    let s3Helper = UserFilesHelper()
    
    
    var nextRoundStarting = false
    var currentRoundFinished = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if leaderId == MyPlayerData.id {
            AvailableRoomHelper.makeMyRoomStatusClosed()
            createBeginingData()
        }
        else {
            InGameHelper.getBeginingGameFromFirB(leaderId: leaderId, completionHandler: { (game, leaderId) in
                DispatchQueue.main.async {
                    self.leaderId = leaderId
                    self.game = game
                    self.reloadCurrentPlayersIcon()
                    self.reloadPreviewCards()
     
                    self.addObserverForCardNormals()
                    self.checkIfYourAreJudge()
                    
                    self.chatHelper.id = game.gameId
                    self.chatHelper.initializeChatObserver(controller: self)
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
    }
    
    func checkIfYourAreJudge(){
        if playerJudging == MyPlayerData.id {
            checkIfAllPlayersHaveInsertCard()
            AddEditJudgeMemeBtn.title = "Judge Your People!"
        }
            
        else if myCardInserted {
            AddEditJudgeMemeBtn.isEnabled = true
            AddEditJudgeMemeBtn.title = "Edit Your Meme"
        }
        else {
            AddEditJudgeMemeBtn.isEnabled = true
            AddEditJudgeMemeBtn.title = "Add Your Meme!"
        }
    }
    
    var playerJoinedFirebaseCount = 0
    
    func addObserverForCardNormals(){
        if(MyPlayerData.id == leaderId){
            inGameRef.child(game.gameId!).child("players").observe(DataEventType.childAdded, with: { (snapshot) in
                DispatchQueue.main.async {
                    self.playerJoinedFirebaseCount = self.playerJoinedFirebaseCount + 1
                    if(self.playerJoinedFirebaseCount == self.playersInGame.count){
                        AvailableRoomHelper.deleteMyRoom()
                    }
                }
            })
        }
        
        
        inGameRef.child(game.gameId!).child("players").observe(DataEventType.childRemoved, with: { (snapshot) in
            DispatchQueue.main.async {
                var count = 0
                for p in self.playersInGame {
                    if(p.userId == snapshot.key){
                        self.playersInGame.remove(at: count)
                    }
                    count = count + 1
                }
                var playerOrder = self.game.playersorder?.allObjects as? [PlayerOrderInGame]
                
                var orderDeleted = 0
                for order in playerOrder! {
                    if order.playerId == snapshot.key {
                        orderDeleted = Int(order.orderNum)
                        self.game.removeFromPlayersorder(order)
                    }
                }
                playerOrder = self.game.playersorder?.allObjects as? [PlayerOrderInGame]
                for order in playerOrder! {
                    if(order.orderNum>orderDeleted){
                        order.orderNum = order.orderNum - Int16(1)
                    }
                }
                GameStack.sharedInstance.saveContext {}
            }
        })
        
        inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childAdded, with: { (snapshot) in
            
            
            
            let playerId = snapshot.key
            
            if playerId != MyPlayerData.id {
                let postDict = snapshot.value as?  [String:Any]
                DispatchQueue.main.async {
                    let cardNormal = self.convertor.getCardNormalFromDictionary(playerId: playerId, dictionary: postDict!)
                    
                    GetGameCoreDataData.getLatestRound(game: self.game).addToCardnormal(cardNormal)
                    self.reloadPreviewCards()
                    
                    if(MyPlayerData.id == self.playerJudging){
                        self.checkIfAllPlayersHaveInsertCard()
                    }
                }
            }
            else {
                self.myCardInserted = true
                self.AddEditJudgeMemeBtn.title = "Edit Your Meme"
            }
        })
        
        
        inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childChanged, with: { (snapshot) in
            let postDict = snapshot.value as?  [String:Any]
            DispatchQueue.main.async {
                let cardNormals = GetGameCoreDataData.getLatestRound(game: self.game).cardnormal?.allObjects as? [CardNormal]
                for card in cardNormals! {
                    if card.playerId == snapshot.key {
                        let temp = self.convertor.getCardNormalFromDictionary(playerId: card.playerId!, dictionary: postDict!)
                        card.bottomText = temp.bottomText
                        card.topText = temp.topText
                        card.didWin = temp.didWin
                        if(temp.didWin){
                            self.AddEditJudgeMemeBtn.isEnabled = false
                            self.currentRoundFinished = true
                            
                            if MyPlayerData.id == self.leaderId {
                            self.inGameRef.child(self.game.gameId!).child("nextRoundStarting").setValue("false", withCompletionBlock: { (error, reference) in
                                if(error != nil){
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.AddEditJudgeMemeBtn.isEnabled = true
                                    self.AddEditJudgeMemeBtn.title = "Start Next Round!"
                                    self.nextRoundStarting = true
                                    self.leaderCreateNewRoundBeforeNextRoundBegin()
                                }
                            })
                            }
                            
                            self.savePeopleWhoLikedYou()
                            if(temp.playerId! == MyPlayerData.id){
                                self.updateNumberOfTimesYouAreCeasar()
                            }
                        }
                        card.playerlove? = (temp.playerlove)!
                        break
                    }
                }
                GameStack.sharedInstance.saveContext {
                    DispatchQueue.main.async {
                        self.reloadPreviewCards()
                    }
                }
            }
        })
        
        // if leader changes due to leaving room
        inGameRef.child(game.gameId!).observe(DataEventType.childChanged, with: { (snapshot) in
            DispatchQueue.main.async {
                if(snapshot.key == "leaderId"){
                    let id = snapshot.value as?  String
                    
                    let oldLeaderId = self.leaderId
                    self.leaderId = id!
                    
                    if MyPlayerData.id == self.leaderId && self.currentRoundFinished {
                        self.AddEditJudgeMemeBtn.title = "Start Next Round!"
                        self.nextRoundStarting = false
                        self.leaderCreateNewRoundBeforeNextRoundBegin()
                    }
                    GameStack.sharedInstance.saveContext {
                    }
                    
                }
                else if(snapshot.key == "nextRoundStarting"){
                    let value = snapshot.value as? String
                    if(value! == "true"){
                    self.inGameRef.child(self.game.gameId!).child("playerOrderInGame").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                            let postDict = snapshot.value as? [String:String]
                            for(playerId,roundNumber) in postDict!{
                                DispatchQueue.main.async {
                                    let orderNumber = Int((roundNumber as? String)!)
                                    self.game.addToPlayersorder(PlayerOrderInGame(orderNum: orderNumber!, playerId: playerId, context: GameStack.sharedInstance.stack.context))
                                    GameStack.sharedInstance.saveContext {
                                        self.loadNextRound()
                                    }
                                }
                            }
                        })
                        
                    }
                }
            }
        })
        
        inGameRef.child(self.game.gameId!).child("playerOrderInGame").observe(DataEventType.childChanged, with: { (snapshot) in
            DispatchQueue.main.async {
                let roundNumber = Int((snapshot.value as? String)!)
                let playerId = snapshot.key as? String
                
                for order in (self.game.playersorder?.allObjects as? [PlayerOrderInGame])!{
                    if(Int(order.orderNum) == roundNumber){
                        order.playerId = playerId
                    }
                }
                
                GameStack.sharedInstance.saveContext {
                }
            }
        })
    }
    
    func savePeopleWhoLikedYou(){
    inGameRef.child(game.gameId!).child("normalCards").child(MyPlayerData.id).child("peopleLiked").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            DispatchQueue.main.async {
                let postDict = snapshot.value as? [String:Any]
                if(postDict == nil){
                    return
                }
                let cardNormals = GetGameCoreDataData.getLatestRound(game: self.game).cardnormal?.allObjects as? [CardNormal]
                    
                for card in cardNormals! {
                    if(card.playerId == MyPlayerData.id){
                        var count = 0
                        for(id,_) in postDict!{
                            card.addToPlayerlove(PlayerLove(playerId: id, context: GameStack.sharedInstance.stack.context))
                            count = count + 1
                        }
                        PlayerDataDynamoDB.updateLaughes(laughes: count, completionHandler: { (error) in
                            if(error != nil){
                                print(error?.description)
                            }
                        })
                        break
                    }
                }
                GameStack.sharedInstance.saveContext {}
            }
        })
    }
    func updateNumberOfTimesYouAreCeasar(){
        PlayerDataDynamoDB.updateMadeCeasar(madeCeasar: 1) { (error) in
            if(error != nil){
                print(error?.description)
            }
        }
    }
    
    func getNextRoundData(completeHandler: @escaping (_ roundJudgeId:String, _ roundNumber: Int)-> Void){
        // create next Round data
        if self.parent == nil {
            return;
        }
        let currentRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: self.game).roundNum)
        let nextRoundNumber = currentRoundNumber + 1
        var nextRoundJudgingId: String!

        for order in (self.game.playersorder?.allObjects as? [PlayerOrderInGame])! {
            if order.orderNum == nextRoundNumber {
                nextRoundJudgingId = order.playerId
            }
        }
        
        GameStack.sharedInstance.saveContext {
            completeHandler(nextRoundJudgingId, nextRoundNumber)
        }
    }
    
    func getNextRoundDataLeader(completeHandler: @escaping (_ roundJudgeId:String, _ roundNumber: Int)-> Void){
        // create next Round data
        let currentRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: self.game).roundNum)
        let nextRoundNumber = currentRoundNumber + 1
        
        playersInGame = playersInGame.shuffled()
        
        let nextRoundJudgingId = playersInGame[0].userId
        
        GameStack.sharedInstance.saveContext {
            completeHandler(nextRoundJudgingId!, nextRoundNumber)
        }
    }
    
    func leaderCreateNewRoundBeforeNextRoundBegin(){
        if(MyPlayerData.id != leaderId){
            return
        }
        getNextRoundDataLeader { (nextRoundJudgeId, nextRoundNumber) in
            DispatchQueue.main.async {
                let helper = UserFilesHelper()
                helper.getRandomMemeData(completeHandler: { (memeData, memeUrl) in
                    DispatchQueue.main.async {
                        InGameHelper.updateGameToNextRound(nextRoundJudgeId: nextRoundJudgeId, gameId: self.game.gameId!, nextRound: nextRoundNumber, nextRoundImageUrl: memeUrl)
                        
                        let nextRound = Round(roundNum: nextRoundNumber, context: GameStack.sharedInstance.stack.context)
                        nextRound.cardceasar = CardCeasar(cardPic: memeData, playerId: nextRoundJudgeId, round: nextRoundNumber, cardPicUrl: memeUrl, context: GameStack.sharedInstance.stack.context)
                        self.playerJudging = nextRoundJudgeId
                        self.game.addToRounds(nextRound)
                        
                        GameStack.sharedInstance.saveContext {
                            DispatchQueue.main.async {
                                self.AddEditJudgeMemeBtn.isEnabled = true
                            }
                        }
                    }
                })
            }
        }
    }
    
    func loadNextRound(){
        myCardInserted = false
        self.currentRoundFinished = true
        clearPreviewCardsData()
        // if I am leader
        if MyPlayerData.id == leaderId {
            self.reloadPreviewCards()
            self.reloadCurrentPlayersIcon()
            self.checkIfYourAreJudge()
        }
        else {
            getNextRoundData(completeHandler: { (nextRoundCeasarId, nextRoundNumber) in
                DispatchQueue.main.async {
                    InGameHelper.getRoundImage(roundNum: nextRoundNumber, gameId: self.game.gameId!, completionHandler: { (imageData, imageUrl) in
                        DispatchQueue.main.async {
                            let nextRound = Round(roundNum: nextRoundNumber, context: GameStack.sharedInstance.stack.context)
                            nextRound.cardceasar = CardCeasar(cardPic: imageData, playerId: nextRoundCeasarId, round: nextRoundNumber, cardPicUrl: imageUrl, context: GameStack.sharedInstance.stack.context)
                            self.playerJudging = nextRoundCeasarId
                            
                            self.game.addToRounds(nextRound)
                            
                            GameStack.sharedInstance.saveContext {
                                DispatchQueue.main.async {
                                    self.reloadPreviewCards()
                                    self.reloadCurrentPlayersIcon()
                                    self.checkIfYourAreJudge()
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    
  
    @IBAction func AddEditJudgeMemeBtnPressed(_ sender: Any) {
        if(AddEditJudgeMemeBtn.title == "Add Your Meme!" || AddEditJudgeMemeBtn.title == "Edit Your Meme"){
            performSegue(withIdentifier: "AddEditMyMemeViewController", sender: self)
        }
        else if(AddEditJudgeMemeBtn.title == "Judge Your People!"){
            self.performSegue(withIdentifier: "JudgingViewControllerSegue", sender: self)
        }
        else if(AddEditJudgeMemeBtn.title == "Start Next Round!"){
            inGameRef.child(game.gameId!).child("nextRoundStarting").setValue("true")
        }
    }
    
    func getCeasarIdForCurrentRound(roundNum: Int) -> String{
        for order in (self.game.playersorder?.allObjects as? [PlayerOrderInGame])! {
            if order.orderNum == roundNum {
                return order.playerId!
            }
        }
        return ""
    }
    
    
    static func getLatestRound(game: Game) -> Round {
        var latestRound: Round!
        var maxNum = -1
        for round in (game.rounds?.allObjects as? [Round])!{
            if Int(round.roundNum) > maxNum {
                maxNum = Int(round.roundNum)
                latestRound = round
            }
        }
        return latestRound
    }

    func checkIfWinnerExist(cards: [CardNormal]) -> Bool{
        var haveWinner = false
        for card in cards {
            if card.didWin {
                haveWinner = true
                break
            }
        }
        return haveWinner
    }
    func checkIfMyCardExist(cards: [CardNormal]) -> Bool{
        var myCardExist = false
        for card in cards {
            if card.playerId == MyPlayerData.id {
                myCardExist = true
                break
            }
        }
        return myCardExist
    }
    
    @IBAction func optionBtnPressed(_ sender: Any) {
        let roomOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        roomOptionAlertController.addAction(UIAlertAction(title: "Leave Room", style: UIAlertActionStyle.default, handler: leaveRoom))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)
    }
    
    private func leaveRoom(action: UIAlertAction){
        inGameRef.removeAllObservers()
        chatHelper.removeChatObserver()
        if(playersInGame.count == 1){
            InGameHelper.removeYourInGameRoom()
            self.chatHelper.removeChatRoom(id: game.gameId!)
            self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
        }
        else {
            for player in playersInGame {
                if player.userId != MyPlayerData.id {
                    InGameHelper.updateLeaderId(newLeaderId: player.userId, gameId: game.gameId!, completionHandler: {
                        DispatchQueue.main.async {
                            InGameHelper.removeYourselfFromGame(gameId: self.game.gameId!, completionHandler: {
                                DispatchQueue.main.async {
                                self.inGameRef.child(self.game.gameId!).child("playerOrderInGame").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                                        let postDict = snapshot.value as? [String:String]
                                        for(playerId,roundNumber) in postDict!{
                                            DispatchQueue.main.async {
                                                let playerOrder = [player.userId:"\(roundNumber)"]
                                                self.inGameRef.child(self.game.gameId!).child("playerOrderInGame").setValue(playerOrder, withCompletionBlock: { (error, reference) in
                                                    DispatchQueue.main.async {
                                                        InGameHelper.removeYourInGameRoom()
                                                        
                                                        self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
                                                    }
                                                })
                                            }
                                        }
                                    })
                                }
                            })
                        }
                    })
                    break
                }
            }

        }
    }
    
    @IBAction func chatSendBtnPressed(_ sender: Any) {
        chatHelper.insertMessage(text: chatTextField.text!)
        chatTextField.text = ""
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
