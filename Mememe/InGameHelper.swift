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
        data["gameId"] = gameId
        
        inGameRef.child(MyPlayerData.id).setValue(data)
    }
    static func getBeginingGameFromFirB(leaderId:String, completionHandler: @escaping (_ game: Game) -> Void){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        inGameRef.child(leaderId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            DispatchQueue.main.async {
                let game = Game(createdDate: Date(), gameId: "", context: delegate.stack.context)
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                
                var roundImageUrl: String!
                
                for(key,value) in postDict {
                    switch(key) {
                    case "gameId":
                        game.gameId = value as! String
                        break
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
                            completionHandler(game)
                        }
                    }
                })
            }
        })
    }
    
    static func updateGameToNextRound(leaderId:String, nextRound: Int, nextRoundImageUrl:String){
        inGameRef.child(leaderId).child("normalCards").removeValue()
        inGameRef.child(leaderId).child("rounds").setValue(nextRoundImageUrl)
    }
    
    static func insertNormalCardIntoGame(leaderId:String, card:CardNormal){
        let value = conversion.getCardDictionaryFromNormalCard(card: card)
        inGameRef.child(leaderId).child("normalCards").child(card.playerId!).setValue(value)
    }
    static func insertNormalCardIntoGame(leaderId:String, card:CardNormal,completionHandler: @escaping () -> Void){
        let value = conversion.getCardDictionaryFromNormalCard(card: card)
        inGameRef.child(leaderId).child("normalCards").child(card.playerId!).setValue(value)
        completionHandler()
    }
    
    static func removeYourInGameRoom(){
        inGameRef.child(MyPlayerData.id).removeValue()
    }
    
    static func getRoundImage(roundNum: Int, leaderId: String, completionHandler: @escaping (_ imageData: Data, _ imageUrl: String) -> Void){
        inGameRef.child(leaderId).child("rounds").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

            let postValue = snapshot.value as? String
        
            let helper = UserFilesHelper()
            helper.getMemeData(memeName: postValue!, completeHandler: { (imageData) in
                completionHandler(imageData,postValue!)
            })
        }
        )
    }
    
    // judging
    static func updateWinnerCard(leaderId: String, cardPlayerId: String){
    inGameRef.child(leaderId).child("normalCards").child(cardPlayerId).child("didWin").setValue(true)
    }

}
