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
        jsonDic["rounds"] = getRoundsDic()
        jsonDic["gameId"] = game.gameId
        jsonDic["winCounter"] = getWinCounterDic()
        
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
    
    private func getWinCounterDic() -> [String:Any] {
        var jsonDic = [String:Any]()
        
        let winCounters = game.wincounter?.allObjects as? [WinCounter]
        for counter in winCounters! {            
            jsonDic["\(counter.playerId!)"] = counter.won
        }
        return jsonDic
    }
    
    private func getPlayersDic() -> [String:Any] {
        var jsonDic = [String:Any]()
        
        let players = game.players?.allObjects as? [Player]
        for player in players! {
            jsonDic["\(player.playerId!)"] = player.name
        }
        return jsonDic
    }
    private func getRoundsDic() -> [String:Any] {
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
