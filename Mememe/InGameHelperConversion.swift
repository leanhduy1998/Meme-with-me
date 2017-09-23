//
//  InGameHelperExtension.swift
//  Mememe
//
//  Created by Duy Le on 9/20/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class InGameHelperConversion {
    private let delegate = UIApplication.shared.delegate as! AppDelegate
    
    func getPlayerFromDictionary(playerId:String, playerData: [String:Any]) -> Player{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let p = Player(laughes: 0, playerName: "", playerId: playerId, score: 0, context: delegate.stack.context)
        
        for (key,value) in playerData {
            switch(key){
            case "laughes":
                p.laughes = value as! Int16
                break
                
            case "score":
                p.score = value as! Int16
                break
                
            case "playerName":
                p.name = value as! String
                break
            default:
                break
            }
        }
        return p
    }
    
    func getCardDictionaryFromNormalCard(card:CardNormal) -> [String:Any] {
        var cardNormals = [String:Any]()
        cardNormals["topText"] = card.topText
        cardNormals["bottomText"] = card.bottomText
        
        
        cardNormals["didWin"] = card.didWin
        
        var loved = [String]()
        for l in (card.playerlove?.allObjects as? [PlayerLove])! {
            loved.append(l.playerId!)
        }
        cardNormals["playerlove"] = loved
        
        return cardNormals
    }
    
    func getCardNormalFromDictionary(playerId:String, dictionary:[String:Any]) -> CardNormal{
        let cardNormal = CardNormal(context: delegate.stack.context)
        cardNormal.playerId = playerId
        
        for (key,value) in dictionary {
            switch(key){
            case "bottomText":
                cardNormal.bottomText = value as! String
                break
            case "didWin":
                cardNormal.didWin = value as! Bool
                break
            case "topText":
                cardNormal.topText = value as! String
                break
            case "playerlove":
                let playerIdWhoLovedThisCard = value as? [String]
                
                for id in playerIdWhoLovedThisCard! {
                    cardNormal.addToPlayerlove(PlayerLove(playerId: id, context: self.delegate.stack.context))
                }
                break
            default:
                print("")
                break
            }
        }
        return cardNormal
    }
}
