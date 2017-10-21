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
        let observer = inGameRef.child(game.gameId!).child("players").observe(DataEventType.childRemoved, with: { (snapshot) in
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
                
                if(snapshot.key == self.playerJudging && (!self.currentRoundFinished)){
                    self.playerJudging = self.leaderId
                    if(MyPlayerData.id == self.leaderId){
                        self.AddEditJudgeMemeBtn.title = "Judge Your People!"
                        self.checkIfAllPlayersHaveInsertCard()
                    }
                    GetGameCoreDataData.getLatestRound(game: self.game).cardceasar?.playerId = self.playerJudging
                }
                GameStack.sharedInstance.saveContext(completeHandler: {
                    DispatchQueue.main.async {
                        self.reloadCurrentPlayersIcon()
                    }
                })
            }
        })
        inGameRefObservers.append(observer)
    }
    
    func addNormalCardsAddedObserver(){
        let observer = inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childAdded, with: { (snapshot) in
            let playerId = snapshot.key
            
            if playerId != MyPlayerData.id {
                let postDict = snapshot.value as?  [String:Any]
                DispatchQueue.main.async {
                    let cardNormal = self.convertor.getCardNormalFromDictionary(playerId: playerId, dictionary: postDict!)
                    
                    GetGameCoreDataData.getLatestRound(game: self.game).addToCardnormal(cardNormal)
                    
                    GameStack.sharedInstance.saveContext(completeHandler: {
                        DispatchQueue.main.async {
                            self.reloadPreviewCards()
                            self.playCardPlacedDown()
                            
                            if(MyPlayerData.id == self.playerJudging){
                                self.checkIfAllPlayersHaveInsertCard()
                            }
                        }
                    })
                }
            }
            else if(playerId == MyPlayerData.id) {
                self.myCardInserted = true
                self.AddEditJudgeMemeBtn.title = "Edit Your Meme"
                self.playCardPlacedDown()
            }
        })
        inGameRefObservers.append(observer)
    }
    func addNormalCardsDeletedObserver(){
        let observer = inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childRemoved, with: { (snapshot) in
            let playerId = snapshot.key
          
            let postDict = snapshot.value as?  [String:Any]
            DispatchQueue.main.async {
                let cards = GetGameCoreDataData.getLatestRound(game: self.game).cardnormal?.allObjects as? [CardNormal]
                
                for card in cards!{
                    if(card.playerId == playerId){
                        GetGameCoreDataData.getLatestRound(game: self.game).removeFromCardnormal(card)
                        break
                    }
                }
                
                GameStack.sharedInstance.saveContext(completeHandler: {
                    DispatchQueue.main.async {
                        if(!self.currentRoundFinished){
                            self.reloadPreviewCards()
                        }
                        
                        if(MyPlayerData.id == self.playerJudging){
                            self.checkIfAllPlayersHaveInsertCard()
                        }
                    }
                })
            }
            
        })
        inGameRefObservers.append(observer)
    }
    func addNormalCardsChangedObserver(){
        let observer = inGameRef.child(game.gameId!).child("normalCards").observe(DataEventType.childChanged, with: { (snapshot) in
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
                        
                        self.nextRoundStarting = true
                        
                        if(MyPlayerData.id == temp.playerId){
                            self.playWinningSound()
                        }
                        else{
                            self.playEndRoundSound()
                        }
                        
                        self.userWhoWon = temp.playerId!
                        
                        for counter in (self.game.wincounter?.allObjects as? [WinCounter])!{
                            if(counter.playerId == temp.playerId){
                                counter.won = counter.won + Int16(1)
                                break
                            }
                        }

                        self.currentRoundFinished = true
                        
                        self.reloadCurrentPlayersIcon()
                        
                        if(MyPlayerData.id != self.leaderId){
                            self.AddEditJudgeMemeBtn.isEnabled = false
                        }
                        
                        if MyPlayerData.id == self.leaderId {
                            self.inGameRef.child(self.game.gameId!).child("nextRoundStarting").setValue("false", withCompletionBlock: { (error, reference) in
                                if(error != nil){
                                    return
                                }
                                DispatchQueue.main.async {
                                    self.AddEditJudgeMemeBtn.title = "Start Next Round!"
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                        self.AddEditJudgeMemeBtn.isEnabled = true
                                    })
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
                GameStack.sharedInstance.saveContext(completeHandler: {
                    DispatchQueue.main.async {
                        self.reloadPreviewCards()
                    }
                })
            }
        })
        inGameRefObservers.append(observer)
    }
    
    func addOtherGameDataChangedObserver(){
        let observer = inGameRef.child(game.gameId!).observe(DataEventType.childChanged, with: { (snapshot) in
            DispatchQueue.main.async {
                // if leader changes due to leaving room
                if(snapshot.key == "leaderId"){
                    let oldLeaderId = self.leaderId
                    self.leaderId = (snapshot.value as?  String)!
                    
                    var count = 0
                    for player in self.playersInGame {
                        if(player.userId == oldLeaderId){
                            self.playersInGame.remove(at: count)
                            break
                        }
                        count = count + 1
                    }
                    
                    if MyPlayerData.id == self.leaderId && self.currentRoundFinished {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            self.AddEditJudgeMemeBtn.isEnabled = true
                        })
                        self.AddEditJudgeMemeBtn.title = "Start Next Round!"
                        
                        self.leaderCreateNewRoundBeforeNextRoundBegin()
                    }
                    else if MyPlayerData.id == self.leaderId && !self.currentRoundFinished{
                        if(oldLeaderId == self.playerJudging){
                            InGameHelper.removeYourCardFromGame(gameId: self.game.gameId!, completionHandler: {
                                DispatchQueue.main.async {
                                    self.playerJudging = MyPlayerData.id
                                    
                                    GetGameCoreDataData.getLatestRound(game: self.game).cardceasar?.playerId = MyPlayerData.id
                                    
                                    GameStack.sharedInstance.saveContext(completeHandler: {
                                        DispatchQueue.main.async {
                                            self.checkIfYourAreJudge()
                                            self.checkIfAllPlayersHaveInsertCard()
                                        }
                                    })
                                }
                            })
                        }
                    }
                    else if MyPlayerData.id != self.leaderId && self.currentRoundFinished{
                        self.AddEditJudgeMemeBtn.isEnabled = false
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
        inGameRefObservers.append(observer)
    }
    func removeAllInGameObservers(){
        for obser in inGameRefObservers {
            inGameRef.removeObserver(withHandle: obser)
        }
    }
}
