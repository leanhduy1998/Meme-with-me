//
//  InGameSwitchingRound.swift
//  Mememe
//
//  Created by Duy Le on 10/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import Firebase

extension InGameViewController{
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
    func getNextRoundDataLeader(completeHandler: @escaping (_ roundJudgeId:String, _ roundNumber: Int)-> Void){
        // create next Round data
        let currentRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: self.game).roundNum)
        let nextRoundNumber = currentRoundNumber + 1
        
        var nextRoundJudgingId: String!
        
        for x in 0...(playersInGame.count - 1){
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
        
        if(playersInGame.count == 1){
            completeHandler(MyPlayerData.id, nextRoundNumber)
        }
        else if(nextRoundJudgingId == nil){
            nextRoundJudgingId = playersInGame[0].userId
        }
        else{
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
                        self.game.addToRounds(nextRound)
                    }
                })
            }
        }
    }
    func loadNextRound(){
        myCardInserted = false
        self.currentRoundFinished = true
        clearPreviewCardsData()
        cardOrder.removeAll()
        cardDictionary.removeAll()
        
        MememeDynamoDB.updateGame(itemToUpdate: gameDBModel!, game: game) { (error) in
            if(error != nil){
                print(error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                // if I am leader
                if MyPlayerData.id == self.leaderId {
                    self.reloadPreviewCards()
                    self.reloadCurrentPlayersIcon()
                    self.checkIfYourAreJudge()
                }
                else {
                    self.setupNextRound()
                }
            }
        }
    }
    private func setupNextRound(){
        let nextRoundNumber = Int(GetGameCoreDataData.getLatestRound(game: game).roundNum) + 1
        
        InGameHelper.getRoundImage( gameId: self.game.gameId!, completionHandler: { (imageData, imageUrl) in
            DispatchQueue.main.async {
                let nextRound = Round(roundNum: nextRoundNumber, context: GameStack.sharedInstance.stack.context)
                nextRound.cardceasar = CardCeasar(cardPic: imageData, playerId: self.playerJudging, round: nextRoundNumber, cardPicUrl: imageUrl, context: GameStack.sharedInstance.stack.context)
                
                self.game.addToRounds(nextRound)
                
                GameStack.sharedInstance.saveContext(completeHandler: {
                    DispatchQueue.main.async {
                        self.reloadPreviewCards()
                        self.reloadCurrentPlayersIcon()
                        self.checkIfYourAreJudge()
                        self.nextRoundStarting = false
                    }
                })
            }
        })
    }
    
}
