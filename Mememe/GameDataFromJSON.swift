//
//  GameDataJSONObjectHelper.swift
//  Mememe
//
//  Created by Duy Le on 8/24/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GameDataFromJSON{
    static var delegate: AppDelegate!
    
    static func getGameFromJSON(model: MememeDBObjectModel, completionHandler: @escaping ()-> Void) -> Game {
        delegate = UIApplication.shared.delegate as! AppDelegate
        
        let gameJSON = model._game
        
        let json = try? JSONSerialization.jsonObject(with: gameJSON!, options: []) as? [String: Any]
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm"
        let createdDate = formatter.date(from: (json!?["createdDate"] as? String)!)
        
        let game = Game(createdDate: createdDate!, gameId: (json??["gameId"] as? String)!, context: delegate.stack.context)
        
        self.addPlayerOrderToGame(game: game, gameDic: (json??["playerOrderInGame"] as? [String:Any])!)
        self.addRoundToGame(game: game, roundDic: (json??["rounds"] as? [String:Any])!)
        
        delegate.saveContext {
            completionHandler()
        }
        return game
    }
    private static func addRoundToGame(game: Game, roundDic: [String:Any]){
        let roundCount = roundDic.count - 1
        
        for x in 0...roundCount {
            let thisRoundDic = roundDic["\(x)"] as? [String:Any]
            let roundCoreData = Round(roundNum: x, context: delegate.stack.context)
            
            addCardCeasarToRound(round: roundCoreData, roundDic: (thisRoundDic?["cardCeasar"] as? [String:Any])!)
            addCardNormalToRound(round: roundCoreData, cardDic: (thisRoundDic?["cardNormals"] as? [String:Any])!)
            
            game.addToRounds(roundCoreData)
        }
    }
    private static func addCardCeasarToRound(round: Round, roundDic: [String:Any]){
        let cardCeasar = CardCeasar(playerId: roundDic["playerId"] as! String, round: Int(round.roundNum), cardPicUrl: roundDic["cardPicUrl"] as! String, context: delegate.stack.context)
        round.cardceasar = cardCeasar
    }
    private static func addCardNormalToRound(round: Round, cardDic: [String:Any]){
        for (playerId,temp) in cardDic {
            var didWin: Bool!
            
            let thisCardDic = temp as! [String:Any]
            
            let didWinTempVal = thisCardDic["didWin"] as? Int
            if didWinTempVal == 0 {
                didWin = false
            }
            else {
                didWin = true
            }
            
            let cardNormal = CardNormal(bottomText: thisCardDic["bottomText"] as! String, didWin: didWin, playerId: playerId, round: Int(round.roundNum), topText: thisCardDic["topText"] as! String, context: delegate.stack.context)
            addPlayerLoveToCardNormal(cardNormal: cardNormal, loveDic: thisCardDic["playerlove"] as! [String])
            round.addToCardnormal(cardNormal)
        }
    }
    private static func addPlayerLoveToCardNormal(cardNormal: CardNormal, loveDic: [String]){
        for playerId in loveDic {
            let playerLove = PlayerLove(playerId: playerId, context: delegate.stack.context)
            cardNormal.addToPlayerlove(playerLove)
        }
    }
    private static func addPlayerOrderToGame(game:Game, gameDic: [String:Any]) {
        for (roundNum,playerId) in gameDic {
            let playerOrder = PlayerOrderInGame(orderNum: Int(roundNum)!, playerId: playerId as! String, context: delegate.stack.context)
            game.addToPlayersorder(playerOrder)
        }
    }
}
