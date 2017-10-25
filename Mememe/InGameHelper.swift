//
//  InGame.swift
//  Mememe
//
//  Created by Duy Le on 9/16/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreData
import UIKit

class InGameHelper{
    private static let inGameRef = Database.database().reference().child("inGame")
    private static let conversion = InGameHelperConversion()
    
    static func insertNewGame(memeUrl: String, playerInRoom:[PlayerData], gameId: String){
        var data = [String:Any]()
        
        var players = [String:Any]()
        for p in playerInRoom {
            var emptyPlayerCharacteristic = [String:Any]()
            emptyPlayerCharacteristic["laughes"] = 0
            emptyPlayerCharacteristic["playerName"] = p.userName
            emptyPlayerCharacteristic["score"] = 0
            
            players[p.userId] = emptyPlayerCharacteristic
        }
        data["players"] =  players
        
        
        let roundMemeUrl = memeUrl
        data["rounds"] = roundMemeUrl
        
        data["playerOrderInGame"] = playerInRoom[0].userId
        data["leaderId"] = MyPlayerData.id
        data["nextRoundStarting"] = "false"
        
        inGameRef.child(gameId).setValue(data)
    }
    
    
    static func updateGameToNextRound(nextRoundJudgeId:String, gameId:String, nextRound: Int, nextRoundImageUrl:String){
        inGameRef.child(gameId).child("normalCards").removeValue()
        inGameRef.child(gameId).child("rounds").setValue(nextRoundImageUrl)
        inGameRef.child(gameId).child("playerOrderInGame").setValue(nextRoundJudgeId)
    }
    
    static func insertNormalCardIntoGame(gameId:String, card:CardNormal){
        let value = conversion.getCardDictionaryFromNormalCard(card: card)
        inGameRef.child(gameId).child("normalCards").child(card.playerId!).setValue(value)
    }
    static func insertNormalCardIntoGame(gameId:String, card:CardNormal,completionHandler: @escaping () -> Void){
        let value = conversion.getCardDictionaryFromNormalCard(card: card)
        inGameRef.child(gameId).child("normalCards").child(card.playerId!).setValue(value)
        completionHandler()
    }
    
    static func removeYourInGameRoom(){
        inGameRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            DispatchQueue.main.async {
                let gameIdAndValue = snapshot.value as? [String : Any]
                if (gameIdAndValue == nil) {
                    return
                }
                
                var leaderIdKeyFound = false
                
                for (gameId,value) in gameIdAndValue! {
                    let gameValue = value as? [String : Any]
                    for (key,value) in gameValue! {
                        let id = value as? String
                        if (key == "leaderId") && (id == MyPlayerData.id) {
                            inGameRef.child(gameId).removeValue()
                            leaderIdKeyFound = true
                            return
                        }
                    }
                }
                
                if !leaderIdKeyFound{
                    for (gameId,value) in gameIdAndValue! {
                        let length = MyPlayerData.id.characters.count
                        let index = gameId.index(gameId.startIndex, offsetBy: length)
                        let leaderId = gameId.substring(to: index)
                        
                        if leaderId == MyPlayerData.id {
                            inGameRef.child(gameId).removeValue()
                        }
                    }
                }
            }
        })
    }
    static func removeYourLeaderInGameRoom(leaderId:String){
        inGameRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            DispatchQueue.main.async {
                let gameIdAndValue = snapshot.value as? [String : Any]
                if (gameIdAndValue == nil) {
                    return
                }
                for (gameId,value) in gameIdAndValue! {
                    let gameValue = value as? [String : Any]
                    for (key,value) in gameValue! {
                        let id = value as? String
                        if (key == "leaderId") && (id == leaderId) {
                            inGameRef.child(gameId).removeValue()
                            break
                        }
                    }
                }
            }
        })
    }
    
    static func getRoundImage(gameId: String, completionHandler: @escaping (_ imageData: Data, _ imageUrl: String) -> Void){
        inGameRef.child(gameId).child("rounds").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

            let postValue = snapshot.value as? String
        
            let helper = UserFilesHelper()
            helper.getMemeData(memeUrl: postValue!, completeHandler: { (imageData) in
                completionHandler(imageData,postValue!)
            })
        }
        )
    }
    
    static func updateLeaderId(newLeaderId: String, gameId:String,completionHandler: @escaping () -> Void){
        inGameRef.child(gameId).child("leaderId").setValue(newLeaderId) { (err, reference) in
            if(err == nil){
                completionHandler()
            }
            else {
                print(err)
            }
        }
    }
    
    static func removeYourselfFromGame(gameId:String,completionHandler: @escaping () -> Void){
        inGameRef.child(gameId).child("players").child(MyPlayerData.id).removeValue { (err, reference) in
            if(err == nil){
                completionHandler()
            }
            else {
                print(err)
            }
        }
    }
    
    static func likeSomeoOneCard(gameId:String, cardId: String){
        inGameRef.child(gameId).child("normalCards").child(cardId).child("peopleLiked").child(MyPlayerData.id).setValue("liked")
    }
    static func unlikeSomeoOneCard(gameId:String, cardId: String){
        inGameRef.child(gameId).child("normalCards").child(cardId).child("peopleLiked").child(MyPlayerData.id).removeValue()
    }
    static func checkIfYouLikedSomeonesCard(gameId:String, cardId: String,completionHandler: @escaping (_ liked: Bool) -> Void){
        inGameRef.child(gameId).child("normalCards").child(cardId).child("peopleLiked").child(MyPlayerData.id).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            let string = snapshot.value as? String
            if(string == nil){
                completionHandler(false)
            }
            else if(string! == "liked"){
                completionHandler(true)
            }
            else{
                completionHandler(false)
            }
        })
    }
    
    static func removeYourCardFromGame(gameId: String, completionHandler: @escaping () -> Void){
        inGameRef.child(gameId).child("normalCards").child(MyPlayerData.id).removeValue { (error, reference) in
            if(error == nil){
                completionHandler()
            }
        }
    }
    
    // judging
    static func updateWinnerCard(gameId: String, cardPlayerId: String){
    inGameRef.child(gameId).child("normalCards").child(cardPlayerId).child("didWin").setValue(true)
    }

}
