//
//  QueryGameData.swift
//  Mememe
//
//  Created by Duy Le on 8/23/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class GameDataToJSON {
    var game: Game!
    init(game:Game) {
        self.game = game
    }
    
    
    func getGameData() -> Data{
        var jsonDic = [String:Any]()
        jsonDic["createdDate"] = getDateString()
        jsonDic["players"] = getPlayersDic()
        jsonDic["rounds"] = getRoundsString()
        jsonDic["playerOrderInGame"] = getPlayerOrderInGame()
        jsonDic["gameId"] = game.gameId
        
        return getJSONfromData(data: jsonDic)
    }
    
    private func getJSONfromData(data: [String:Any]) -> Data{
        let validDictionary = data
        
        var rawData: Data!
        do {
            rawData = try JSONSerialization.aws_data(withJSONObject: validDictionary, options: .prettyPrinted)
        } catch {
            // Handle Error
        }
        return rawData
    }
    
    
    private func getPlayersDic() -> [String:Any] {
        var jsonDic = [String:Any]()
        
        let players = game.players?.allObjects as? [Player]
        for player in players! {
            
            var playerDic = [String: Any]()
            playerDic["laughes"] = Int(player.laughes)
            playerDic["score"] = Int(player.score)
            
            jsonDic["\(player.playerId!)"] = playerDic
        }
        return jsonDic
    }
    private func getRoundsString() -> [String:Any] {
        var jsonDic = [String:Any]()
        
        let rounds = game.rounds?.allObjects as? [Round]
        for round in rounds! {
            var roundDic = [String: Any]()
            roundDic["cardNormals"] = getCardNormalsDic(round: round)
            roundDic["cardCeasar"] = getCeasarCardDic(round: round)
            
            jsonDic["\(Int(round.roundNum))"] = roundDic
        }
        return jsonDic
    }
    private func getCardNormalsDic(round: Round) -> [String:Any] {
        var jsonDic = [String:Any]()
        
        let cardNormals = round.cardnormal?.allObjects as? [CardNormal]
        
        for card in cardNormals! {
            var cardDic = [String: Any]()
            cardDic["bottomText"] = card.bottomText!
            cardDic["topText"] = card.topText!
            cardDic["didWin"] = card.didWin
            cardDic["playerlove"] = getLovedByArray(card: card)
            
            jsonDic[card.playerId!] = cardDic
        }
        
        return jsonDic
    }
    private func getLovedByArray(card: CardNormal) -> [String]  {
        var stringArr = [String]()
        
        for loved in (card.playerlove?.allObjects as? [PlayerLove])! {
            stringArr.append(loved.playerId!)
        }
        
        return stringArr
    }
    private func getCeasarCardDic(round: Round) -> [String:Any]{
        let cardCeasar = round.cardceasar
        
        var ceasarArr = [String:Any]()
        ceasarArr["cardPicUrl"] = cardCeasar?.cardPicUrl
        ceasarArr["playerId"] = cardCeasar?.playerId
        
        return ceasarArr
    }
    private func getPlayerOrderInGame() -> [String:Any] {
        var orderDic = [String:Any]()
        
        let playerOrders = game.playersorder?.allObjects as? [PlayerOrderInGame]
        
        for order in playerOrders! {
            orderDic["\(Int(order.orderNum))"] = order.playerId!
        }
        
        return orderDic
    }
    
    func getGameCreatedDate() -> Int {
        return GetGameData.getDateInt(date: game.createdDate! as Date)
    }
    private func getDateString() -> String{
        let date = game.createdDate as Date?
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm"
        
        let dateString = formatter.string(from: date!)
        return dateString
    }
}
