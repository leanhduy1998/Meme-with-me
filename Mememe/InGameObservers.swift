//
//  InGameObservers.swift
//  Mememe
//
//  Created by Duy Le on 10/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import Firebase

extension InGameViewController{
    func addPlayerRemovedObserver(){
        inGameRef.child(game.gameId!).child("players").observe(DataEventType.childRemoved, with: { (snapshot) in
            DispatchQueue.main.async {
                var count = 0
                for p in self.playersInGame {
                    if(p.userId == snapshot.key){
                        self.playersInGame.remove(at: count)
                    }
                    count = count + 1
                }
                
                if(self.playersInGame.count == 1){
                    self.AddEditJudgeMemeBtn.isEnabled = false
                }
                self.reloadCurrentPlayersIcon()
            }
        })
    }
    
    func addNormalCardsAddedObserver(){
        inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childAdded, with: { (snapshot) in
            let playerId = snapshot.key
            
            if playerId != MyPlayerData.id {
                let postDict = snapshot.value as?  [String:Any]
                DispatchQueue.main.async {
                    let cardNormal = self.convertor.getCardNormalFromDictionary(playerId: playerId, dictionary: postDict!)
                    
                    GetGameCoreDataData.getLatestRound(game: self.game).addToCardnormal(cardNormal)
                    self.reloadPreviewCards()
                    self.playCardPlacedDown()
                    
                    if(MyPlayerData.id == self.playerJudging){
                        self.checkIfAllPlayersHaveInsertCard()
                    }
                }
            }
            else {
                self.myCardInserted = true
                self.AddEditJudgeMemeBtn.title = "Edit Your Meme"
                self.playCardPlacedDown()
            }
        })
    }
    func addNormalCardsChangedObserver(){
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
                        card.playerlove? = (temp.playerlove)!
                        
                        if(!temp.didWin){
                            break
                        }
                        
                        if(MyPlayerData.id == temp.playerId){
                            self.playWinningSound()
                        }
                        else{
                            self.playEndRoundSound()
                        }
                        
                        self.userWhoWon = temp.playerId!
                        
                        self.AddEditJudgeMemeBtn.isEnabled = false
                        self.currentRoundFinished = true
                        
                        self.reloadCurrentPlayersIcon()
                        
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
    }
    
    func addOtherGameDataChangedObserver(){
        inGameRef.child(game.gameId!).observe(DataEventType.childChanged, with: { (snapshot) in
            DispatchQueue.main.async {
                // if leader changes due to leaving room
                if(snapshot.key == "leaderId"){
                    self.leaderId = (snapshot.value as?  String)!
                    
                    if MyPlayerData.id == self.leaderId && self.currentRoundFinished {
                        self.AddEditJudgeMemeBtn.title = "Start Next Round!"
                        self.nextRoundStarting = false
                        self.leaderCreateNewRoundBeforeNextRoundBegin()
                    }
                }
                else if(snapshot.key == "nextRoundStarting"){
                    let value = snapshot.value as? String
                    if(value! == "true"){
                        self.loadNextRound()
                    }
                }
                else if(snapshot.key == "playerOrderInGame"){
                    let playerId = snapshot.value as? String
                    self.playerJudging = playerId
                }
            }
        })
    }
}
