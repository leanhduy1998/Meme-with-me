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

class InGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var AddEditJudgeMemeBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var nextRoundStatus: UILabel!
    
    @IBAction func unwindToInGameViewController(segue:UIStoryboardSegue) { }
    //ui
    var screenWidth : CGFloat!
    var screenHeight : CGFloat!
    let space = CGFloat(10)
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
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    //database
    let inGameRef = Database.database().reference().child("inGame")
    private let convertor = InGameHelperConversion()
    
    //timer
    private var timeTillNextRoundTimer = Timer()
    private var countDownNumber = 15
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if leaderId == MyPlayerData.id {
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
                }
            })
        }
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nextRoundStatus.isHidden = true
        if game != nil {
            reloadPreviewCards()
        }
    }
    
    func checkIfYourAreJudge(){
        if playerJudging == MyPlayerData.id {
            checkIfAllPlayersHaveInsertCard()
            AddEditJudgeMemeBtn.isEnabled = false
            AddEditJudgeMemeBtn.title = "Judge Your People!"
        }
        else {
            AddEditJudgeMemeBtn.isEnabled = true
            AddEditJudgeMemeBtn.title = "Add Your Meme!"
        }
    }
    
    func addObserverForCardNormals(){
        print(game.gameId!)
        inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childAdded, with: { (snapshot) in
            let playerId = snapshot.key
            
            if playerId != MyPlayerData.id {
                let postDict = snapshot.value as?  [String:Any]
                DispatchQueue.main.async {
                    let cardNormal = self.convertor.getCardNormalFromDictionary(playerId: playerId, dictionary: postDict!)
                    
                    GetGameCoreDataData.getLatestRound(game: self.game).addToCardnormal(cardNormal)
                    self.reloadPreviewCards()
                }
            }
            else {
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
                            self.nextRoundStatus.isHidden = false
                            self.AddEditJudgeMemeBtn.isEnabled = false
                            
                            if MyPlayerData.id == self.leaderId {
                                self.countDownNumber = 9
                            }
                            else {
                                self.countDownNumber = 12
                            }
                            
                            self.timeTillNextRoundTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownTillNextRound), userInfo: nil, repeats: true)
                            self.timeTillNextRoundTimer.fire()
                            
                        }
                        card.playerlove? = (temp.playerlove)!
                        break
                    }
                }
                self.delegate.saveContext {
                    DispatchQueue.main.async {
                        self.reloadPreviewCards()
                    }
                }
            }
        })
        
        inGameRef.child(game.gameId!).observe(DataEventType.childChanged, with: { (snapshot) in
            DispatchQueue.main.async {
                let id = snapshot.value as?  String
                
                let oldLeaderId = self.leaderId
                self.leaderId = id!
                
                let playerOrder = self.game.playersorder?.allObjects as? [PlayerOrderInGame]
                
                var roundNumRemoved = 0
                for order in playerOrder! {
                    if order.playerId == oldLeaderId {
                        roundNumRemoved = Int(order.orderNum)
                        self.game.removeFromPlayersorder(order)
                        break
                    }
                }
                

                for order in playerOrder! {
                    if Int(order.orderNum) > roundNumRemoved {
                        order.orderNum = order.orderNum - Int16(1)
                    }
                }
            }
        })
    }
    
    func countDownTillNextRound(){
        nextRoundStatus.text = "Time till next round: \(countDownNumber) second(s)"
        
        if(countDownNumber == 0){
            timeTillNextRoundTimer.invalidate()
            nextRoundStatus.isHidden = true
            
            let nextRound = Int(GetGameCoreDataData.getLatestRound(game: self.game).roundNum) + 1
            
            if(nextRound > (game.playersorder?.count)!-1) {
                let playerOrder = game.playersorder?.allObjects as? [PlayerOrderInGame]
                for order in playerOrder! {
                    let temp = PlayerOrderInGame(orderNum: Int(order.orderNum) + (playerOrder?.count)!, playerId: order.playerId!, context: delegate.stack.context)
                    game.addToPlayersorder(temp)
                    print(playerOrder?.count)
                }
            }
            
            let nextRoundCeasarId = getCeasarIdForCurrentRound(roundNum: nextRound)
            
            let round = Round(roundNum: nextRound, context: self.delegate.stack.context)
            
            if MyPlayerData.id == leaderId {
                let helper = UserFilesHelper()
                helper.getRandomMemeData(completeHandler: { (memeData, memeUrl) in
                    DispatchQueue.main.async {
                        InGameHelper.updateGameToNextRound(gameId: self.game.gameId!, nextRound: nextRound, nextRoundImageUrl: memeUrl)
                        
                        round.cardceasar = CardCeasar(cardPic: memeData, playerId: nextRoundCeasarId, round: nextRound, cardPicUrl: memeUrl, context: self.delegate.stack.context)
                        self.game.addToRounds(round)
                        
                        self.delegate.saveContext {
                            DispatchQueue.main.async {
                                self.reloadPreviewCards()
                                self.reloadCurrentPlayersIcon()
                            }
                        }
                    }
                })
            }
            else {
                InGameHelper.getRoundImage(roundNum: nextRound, gameId: game.gameId!, completionHandler: { (imageData, imageUrl) in
                    DispatchQueue.main.async {
                        round.cardceasar = CardCeasar(cardPic: imageData, playerId: nextRoundCeasarId, round: nextRound, cardPicUrl: imageUrl, context: self.delegate.stack.context)
                        self.game.addToRounds(round)
                        
                        self.delegate.saveContext {
                            DispatchQueue.main.async {
                                self.reloadPreviewCards()
                                self.reloadCurrentPlayersIcon()
                            }
                        }
                    }
                })
                
            }
        }
        countDownNumber = countDownNumber - 1
    }
    
    
  
    @IBAction func AddEditJudgeMemeBtnPressed(_ sender: Any) {
        if MyPlayerData.id == playerJudging {
            self.performSegue(withIdentifier: "JudgingViewControllerSegue", sender: self)
        }
        else {
            performSegue(withIdentifier: "AddEditMyMemeViewController", sender: self)
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
        roomOptionAlertController.addAction(UIAlertAction(title: "End Game", style: UIAlertActionStyle.default, handler: endGame))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)
    }
    
    private func leaveRoom(action: UIAlertAction){
        for player in playersInGame {
            if player.userId != MyPlayerData.id {
                InGameHelper.updateLeaderId(newLeaderId: player.userId, gameId: game.gameId!)
                break
            }
        }
        InGameHelper.removeYourInGameRoom()
        inGameRef.removeAllObservers()
        dismiss(animated: true, completion: nil)
    }
    private func endGame(action: UIAlertAction){
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    }
}
