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
    
    static func insertNewGame(memeName: String, playerInRoom:[PlayerData], playerOrder:[PlayerOrderInGame], gameId: String){
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
        
        
        let roundMemeUrl = memeName
        data["rounds"] = roundMemeUrl
        
        var orders = [String:String]()
        for o in playerOrder {
            orders[o.playerId!] = "\(Int(o.orderNum))"
        }
        
        data["playerOrderInGame"] = orders
        data["leaderId"] = MyPlayerData.id
        
        inGameRef.child(gameId).setValue(data)
    }
    static func getBeginingGameFromFirB(leaderId:String, completionHandler: @escaping (_ game: Game, _ leaderId:String) -> Void){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        inGameRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let gameIdAndValue = snapshot.value as? [String : Any]
            for (gameId,value) in gameIdAndValue! {
                if gameId.contains(leaderId) {
                    DispatchQueue.main.async {
                        var leaderId: String!
                        let game = Game(createdDate: Date(), gameId: gameId, context: delegate.stack.context)
                        let postDict = value as? [String : AnyObject] ?? [:]
                        
                        var roundImageUrl: String!
                        
                        for(key,value) in postDict {
                            switch(key) {
                            case "playerOrderInGame":
                                let orders = value as? [String : AnyObject] ?? [:]
                                for (playerId,number) in orders {
                                    let playerOrder = PlayerOrderInGame(orderNum: Int(number as! String)!, playerId: playerId, context: delegate.stack.context)
                                    game.addToPlayersorder(playerOrder)
                                }
                                break
                                
                            case "players":
                                let players = value as? [String : AnyObject] ?? [:]
                                
                                for (playerId,playerData) in players {
                                    let player = conversion.getPlayerFromDictionary(playerId: playerId, playerData: playerData as! [String : Any])
                                    game.addToPlayers(player)
                                }
                                break
                                
                            case "rounds":
                                roundImageUrl = value as? String
                                break
                            case "leaderId":
                                leaderId = value as? String
                                break
                                
                            default:
                                break
                            }
                        }
                        let round = Round(roundNum: 0, context: delegate.stack.context)
                        
                        var playerId = ""
                        
                        for order in (game.playersorder?.allObjects as? [PlayerOrderInGame])! {
                            if order.orderNum == round.roundNum {
                                playerId = order.playerId!
                                break
                            }
                        }
                        
                        let helper = UserFilesHelper()
                        helper.getMemeData(memeName: roundImageUrl, completeHandler: { (imageData) in
                            DispatchQueue.main.async {
                                let cardCeasar = CardCeasar(cardPic: imageData, playerId: playerId, round: 0, cardPicUrl: roundImageUrl, context: delegate.stack.context)
                                round.cardceasar = cardCeasar
                                game.addToRounds(round)
                                
                                delegate.saveContext {
                                    completionHandler(game, leaderId)
                                }
                            }
                        })
                    }
                }
            }
            
        })
    }
    
    
    static func updateGameToNextRound(gameId:String, nextRound: Int, nextRoundImageUrl:String){
        inGameRef.child(gameId).child("normalCards").removeValue()
        inGameRef.child(gameId).child("rounds").setValue(nextRoundImageUrl)
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
                if (gameIdAndValue != nil) {
                    for (gameId,value) in gameIdAndValue! {
                        let gameValue = value as? [String : Any]
                        for (key,value) in gameValue! {
                            let id = value as? String
                            print(MyPlayerData.id)
                            if (key == "leaderId") && (id == MyPlayerData.id) {
                                inGameRef.child(gameId).removeValue()
                                break
                            }
                        }
                    }
                }
            }
        })
    }
    
    static func getRoundImage(roundNum: Int, gameId: String, completionHandler: @escaping (_ imageData: Data, _ imageUrl: String) -> Void){
        inGameRef.child(gameId).child("rounds").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

            let postValue = snapshot.value as? String
        
            let helper = UserFilesHelper()
            helper.getMemeData(memeName: postValue!, completeHandler: { (imageData) in
                completionHandler(imageData,postValue!)
            })
        }
        )
    }
    
    // judging
    static func updateWinnerCard(gameId: String, cardPlayerId: String){
    inGameRef.child(gameId).child("normalCards").child(cardPlayerId).child("didWin").setValue(true)
    }

}
