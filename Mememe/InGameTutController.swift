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

class InGameTutController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate, UITextFieldDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    @IBOutlet weak var AddEditJudgeMemeBtn: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var floorBackground: UIImageView!
    
    @IBOutlet weak var chatSendBtn: UIButton!
    
    
    
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
    let s3Helper = UserFilesHelper()
    //controller
    var thisRoundImage: UIImage!
    var playerJudging: String!

    var leaderId = ""
    var borderForUserIconIV = UIImageView()

    var myCardInserted = false
    var userWhoWon = ""
    
    var playersInGame = [PlayerData]()
    
    var game:Game!
    var messages = [ChatModel]()
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    
    //sound player
    var backgroundPlayer:AVAudioPlayer!
    var effectPlayer:AVAudioPlayer!
    
    // animation
    var cardInitialYBeforeAnimation: CGFloat!
    
    // tut
    var step3Finished = false
    var step6Finished = false
    var step7Finished = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createBeginingData()

        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(!step3Finished && !step6Finished && !step7Finished){
            alertController = UIAlertController(title: "This is your game!", message: "Let's go through the rules!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.default, handler: step2))
            
            alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
    }
    func step2(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        alertController = UIAlertController(title: "The ruler!", message: "There will be a Ceasar to choose a winner each round.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.default, handler: step3))
        alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func step3(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        alertController = UIAlertController(title: "The citizen!", message: "This round you will be a citizen. Try to add your card with the top right button!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func step4(){
        letUserWin()
        alertController = UIAlertController(title: "Congrats! The bot chose you!", message: "You won! Look at your card! Also, every time you open the app, Mememe will tell you how many times you are chosen by the Caesar!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.default, handler: step5))
        present(alertController, animated: true, completion: nil)
    }
    
    func step5(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.clearPreviewCardsData()
            self.reloadPreviewCards()
            
            self.AddEditJudgeMemeBtn.isEnabled = true
            
            self.alertController = UIAlertController(title: "A new round has started! This time you are Ceasar!", message: "Every round each player will be Ceasar in turn. Just like the circle of life!", preferredStyle: UIAlertControllerStyle.alert)
            self.alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.default, handler: self.step6))
            self.alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(self.alertController, animated: true, completion: nil)
        })
    }
    
    //self.alertController = UIAlertController(title: "", message: " ", preferredStyle:
    
    func step6(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        self.alertController = UIAlertController(title: "Did you know?", message: "You can double tap on any card that is not yours to like it. Also, every time you open the app, Mememe will tell you how many times people laughed at your cards! Try it out to continue!", preferredStyle: UIAlertControllerStyle.alert)
        self.alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(self.alertController, animated: true, completion: nil)
    }
    
    func step7(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.alertController = UIAlertController(title: "All hail Caesar!", message: "Now you are the Caesar! When all the cards are submitted, you can judge them! Tap on the judge button on the top right!", preferredStyle: UIAlertControllerStyle.alert)
            self.alertController.addAction(UIAlertAction(title: "Okay!", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(self.alertController, animated: true, completion: nil)
        })
    }
    
    func finalStep(){
        self.alertController = UIAlertController(title: "A winner has been chosen!", message: "All hail Ceasar!", preferredStyle: UIAlertControllerStyle.alert)
        self.alertController.addAction(UIAlertAction(title: "Finish tutorial", style: UIAlertActionStyle.default, handler: quitTutorial))
        self.present(self.alertController, animated: true, completion: nil)
    }
    func quitTutorial(action: UIAlertAction){
        performSegue(withIdentifier: "unwindToAvailableGamesViewControllerFromInGameTut", sender: self)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        playBackground()
        
        if(step3Finished && !step6Finished && !step7Finished){
            step4()
        }
        else if(step3Finished && step7Finished){
            finalStep()
        }
    }
    
    
    
    @IBAction func AddEditJudgeMemeBtnPressed(_ sender: Any) {
        if(AddEditJudgeMemeBtn.title == "Add Your Meme!" || AddEditJudgeMemeBtn.title == "Edit Your Meme"){
            performSegue(withIdentifier: "AddEditTutControllerSegue", sender: self)
        }
        else if(AddEditJudgeMemeBtn.title == "Judge Your People!"){
            self.performSegue(withIdentifier: "JudgingTutControllerSegue", sender: self)
        }
        else if(AddEditJudgeMemeBtn.title == "Start Next Round!"){
            
        }
    }
    
    @IBAction func optionBtnPressed(_ sender: Any) {
        let roomOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        roomOptionAlertController.addAction(UIAlertAction(title: "End tutorial!", style: UIAlertActionStyle.default, handler: quitTutorial))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)
    }
    
    
    func setAddEditJudgeMemeBtnUI(ceasarId: String, haveWinner: Bool) {
        if haveWinner {
            AddEditJudgeMemeBtn.isEnabled = false
        }
        else {
            checkIfYourAreJudge()
        }
    }
    func checkIfYourAreJudge(){
        if playerJudging == MyPlayerData.id {
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
    
    func createBeginingData(){
        let date = Date()
        self.game = Game(createdDate: date, gameId: self.leaderId + "\(0)", context: GameStack.sharedInstance.stack.context)
        
        self.game.addToPlayers(Player(laughes: 0, playerName: MyPlayerData.name, playerId: MyPlayerData.id, score: 0, context: GameStack.sharedInstance.stack.context))
        self.game.addToPlayers(Player(laughes: 0, playerName: "bot1", playerId: "b1", score: 0, context: GameStack.sharedInstance.stack.context))
        self.game.addToPlayers(Player(laughes: 0, playerName: "bot2", playerId: "b2", score: 0, context: GameStack.sharedInstance.stack.context))
        
        
        let round = Round(roundNum: 0, context: GameStack.sharedInstance.stack.context)
        
        self.playerJudging = self.playersInGame[0].userId
        
        let ceasarCard = CardCeasar(cardPic: Data(), playerId: self.playerJudging, round: Int(round.roundNum), cardPicUrl: "ceasarUrl", context: GameStack.sharedInstance.stack.context)
        
        round.cardceasar = ceasarCard
        self.game.addToRounds(round)
        
        self.reloadCurrentPlayersIcon()
        self.reloadPreviewCards()
        self.checkIfYourAreJudge()

    }
    
    func getNextRoundDataLeader(completeHandler: @escaping (_ roundJudgeId:String, _ roundNumber: Int)-> Void){
        // create next Round data
        let currentRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: self.game).roundNum)
        let nextRoundNumber = currentRoundNumber + 1
        
        var nextRoundJudgingId: String!
        
        var count = 0
        
        for x in 0...(playersInGame.count - 1){
            print(x)
            if(playersInGame[x].userId == playerJudging){
                if(x == playersInGame.count-1){
                    nextRoundJudgingId = playersInGame[0].userId
                    break
                }
                else{
                    nextRoundJudgingId = playersInGame[x+1].userId
                    break
                }
            }
        }
        completeHandler(nextRoundJudgingId!, nextRoundNumber)
    }
    
    func letUserWin(){
        AddEditJudgeMemeBtn.isEnabled = false
        let lastestRound = GetGameCoreDataData.getLatestRound(game: game)
        let cards = lastestRound.cardnormal?.allObjects as? [CardNormal]
        
        for card in cards!{
            if(card.playerId == MyPlayerData.id){
                card.didWin = true
                userWhoWon = MyPlayerData.id
                reloadCurrentPlayersIcon()
                reloadPreviewCards()
                
                leaderCreateNewRoundBeforeNextRoundBegin()
            }
        }
    }

    func leaderCreateNewRoundBeforeNextRoundBegin(){
        getNextRoundDataLeader { (nextRoundJudgeId, nextRoundNumber) in
            DispatchQueue.main.async {
                let nextRound = Round(roundNum: nextRoundNumber, context: GameStack.sharedInstance.stack.context)
                nextRound.cardceasar = CardCeasar(cardPic: Data(), playerId: nextRoundJudgeId, round: nextRoundNumber, cardPicUrl: "asd", context: GameStack.sharedInstance.stack.context)
                nextRound.addToCardnormal(CardNormal(bottomText: "Bot's meme joke", didWin: false, playerId: "b1", round: nextRoundNumber, topText: "You won't understand", context: GameStack.sharedInstance.stack.context))
                nextRound.addToCardnormal(CardNormal(bottomText: "What she says", didWin: false, playerId: "b2", round: nextRoundNumber, topText: "I agree", context: GameStack.sharedInstance.stack.context))
                self.game.addToRounds(nextRound)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        unsubscribeFromKeyboardNotifications()
        if let destination = segue.destination as? AddEditTutController {
            destination.myPlayerId = MyPlayerData.id
            destination.memeImage = thisRoundImage
            destination.game = game
            destination.leaderId = leaderId
        }
        else if let destination = segue.destination as? JudgingTutController {
            destination.game = game
            destination.playerJudging = playerJudging
            destination.leaderId = leaderId
        }
    }
}

