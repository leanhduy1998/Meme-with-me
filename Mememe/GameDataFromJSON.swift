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
    
    static func getGameJSONModelFromJSON(model: MememeDBObjectModel) -> GameJSONModel {
        let gameJSON = model._game
        
        let json = try? JSONSerialization.jsonObject(with: gameJSON!, options: []) as? [String: Any]
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm"
        let createdDate = formatter.date(from: (json!?["createdDate"] as? String)!)
        
        let game = GameJSONModel(createdDate: createdDate!, gameId: (json??["gameId"] as? String)!, model: model)
        self.addRoundToGameJSONModel(game: game, roundDic: (json??["rounds"] as? [String:Any])!)
        self.addPlayersToGameJSONModel(game: game, playersDic: (json??["players"] as? [String:[String:String]])!)
        self.addWinCounterToGameJSONModel(game: game, winCountDic: (json??["winCounter"] as? [String:Int])!)
        return game
    }
    
    static func saveGameCoreDataFromJSON(model: MememeDBObjectModel, imageDownloaded:[String:UIImage], completeHandler: @escaping ()-> Void){
        let gameJSON = model._game
        
        let json = try? JSONSerialization.jsonObject(with: gameJSON!, options: []) as? [String: Any]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm"
        let createdDate = formatter.date(from: (json!?["createdDate"] as? String)!)
        
        let game = Game(createdDate: createdDate!, gameId: (json??["gameId"] as? String)!, context: GameStack.sharedInstance.stack.context)
        
        self.addPlayersToGame(game: game, playersDic: (json??["players"] as? [String:[String:String]])!, imageDownloaded: imageDownloaded)
        self.addWinCounterToGame(game: game, winCountDic: (json??["winCounter"] as? [String:Int])!)
        
        self.addRoundToGame(game: game, roundDic: (json??["rounds"] as? [String:Any])!, completeHandler: {
            DispatchQueue.main.async {
                GameStack.sharedInstance.saveContext {
                    completeHandler()
                }
            }
        })
        
    }
    private static func addPlayersToGame(game: Game, playersDic: [String:[String:String]],imageDownloaded:[String:UIImage]){
        for(playerId,playerDic2) in playersDic {
            var name:String!
            for(key,value) in playerDic2 {
                if key == "name"{
                    name = value
                }
            }
            let playerIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: playerId)
            let gameIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: game.gameId!)
            
            let directory: [String] = ["Game","\(gameIdForStorage)"]
            
            let image = imageDownloaded[playerId]
            
            let imageLocation = FileManagerHelper.insertImageIntoMemory(imageName: playerIdForStorage, directory: directory, image: image!)
            
            

            game.addToPlayers(Player(playerName: name, playerId: playerId, userImageLocation: imageLocation, context: GameStack.sharedInstance.stack.context))
        }
    }
    private static func addPlayersToGameJSONModel(game: GameJSONModel, playersDic: [String:[String:String]]){
        for(playerId,playerDic2) in playersDic {
            var name:String!
            var imageLocation: String!
            for(key,value) in playerDic2 {
                if key == "name"{
                    name = value
                }
                if key == "imageStorageLocation" {
                    imageLocation = value
                }
            }
            game.player.append(PlayerJSONModel(playerName: name, playerId: playerId, userImageLocation: imageLocation!))
        }
    }
    
    private static func addWinCounterToGame(game: Game, winCountDic: [String:Int]){
        for(playerId,winCount) in winCountDic {
            game.addToWincounter(WinCounter(playerId: playerId, wonNum: winCount, context: GameStack.sharedInstance.stack.context))
        }
    }
    private static func addWinCounterToGameJSONModel(game: GameJSONModel, winCountDic: [String:Int]){
        for(playerId,winCount) in winCountDic {
            game.winCounter.append(WinCounterJSONModel(playerId: playerId, wonNum: winCount))
        }
    }
    
    private static func addRoundToGame(game: Game, roundDic: [String:Any],completeHandler: @escaping ()-> Void){
        let roundCount = roundDic.count - 1
        
        for x in 0...roundCount {
            let thisRoundDic = roundDic["\(x)"] as? [String:Any]
            let roundCoreData = Round(roundNum: x, context: GameStack.sharedInstance.stack.context)
            
            addCardCeasarToRound(gameId: game.gameId! ,round: roundCoreData, roundDic: (thisRoundDic?["cardCeasar"] as? [String:Any])!, completeHandler: {
                DispatchQueue.main.async {
                    addCardNormalToRound(round: roundCoreData, cardDic: (thisRoundDic?["cardNormals"] as? [String:Any])!)
                    addRoundPlayersToRound(round: roundCoreData, playerDic: thisRoundDic!["players"] as! [String : [String : String]])
                    
                    game.addToRounds(roundCoreData)
                    completeHandler()
                }
            })
        }
    }
    private static func addRoundToGameJSONModel(game: GameJSONModel, roundDic: [String:Any]){
        let roundCount = roundDic.count - 1
        
        for x in 0...roundCount {
            let thisRoundDic = roundDic["\(x)"] as? [String:Any]
            let roundCoreData = RoundJSONModel(roundNum: x)
            
            addCardNormalToRoundJSONModel(round: roundCoreData, cardDic: (thisRoundDic?["cardNormals"] as? [String:Any])!)
            addRoundPlayersToRoundJSONModel(round: roundCoreData, playerDic: thisRoundDic!["players"] as! [String : [String : String]])
            
            addCardCeasarToRoundJSONModel(gameId: game.gameId! ,round: roundCoreData, roundDic: (thisRoundDic?["cardCeasar"] as? [String:Any])!, completeHandler: {round in
                game.rounds.append(round)
            })
        }
    }
    
    private static func addRoundPlayersToRound(round: Round, playerDic: [String:[String:String]]){
        for(playerId,dic) in playerDic {
            var name:String!
            var imageLocation: String!
            for(key,value) in dic {
                if key == "name"{
                    name = value
                }
                else if key == "imageStorageLocation"{
                    imageLocation = value
                }
            }
            round.addToPlayers(Player(playerName: name, playerId: playerId, userImageLocation: imageLocation, context: GameStack.sharedInstance.stack.context))
        }
    }
    private static func addRoundPlayersToRoundJSONModel(round: RoundJSONModel, playerDic: [String:[String:String]]){
        for(playerId,dic) in playerDic {
            var name:String!
            var imageLocation: String!
            for(key,value) in dic {
                if key == "name"{
                    name = value
                }
                else if key == "imageStorageLocation"{
                    imageLocation = value
                }
            }
            round.players.append(PlayerJSONModel(playerName: name, playerId: playerId, userImageLocation: imageLocation))
        }
    }
    
    private static func addCardCeasarToRound(gameId: String, round: Round, roundDic: [String:Any],completeHandler: @escaping ()-> Void){
        let helper = UserFilesHelper()
        
        let playerId = roundDic["playerId"] as! String
        
        let gameIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: gameId)
        
        helper.getMemeData(memeUrl: roundDic["cardDBUrl"] as! String) { (memeData) in
            DispatchQueue.main.async {
                let directory: [String] = ["Game","\(gameIdForStorage)"]
                
                let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "round\(Int(round.roundNum))", directory: directory, image: UIImage(data: memeData)!)
                let cardCeasar = CardCeasar(playerId: playerId, round: Int(round.roundNum), cardDBurl: roundDic["cardDBUrl"] as! String, imageStorageLocation: filePath, context: GameStack.sharedInstance.stack.context)
                round.cardceasar = cardCeasar
                completeHandler()
            }
        }
    }
    private static func addCardCeasarToRoundJSONModel(gameId: String, round: RoundJSONModel, roundDic: [String:Any], completeHandler: @escaping (_ round: RoundJSONModel)-> Void){
        let helper = UserFilesHelper()
        
        let playerId = roundDic["playerId"] as! String
        
        let gameIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: gameId)
        
        helper.getMemeData(memeUrl: roundDic["cardDBUrl"] as! String) { (memeData) in
            DispatchQueue.main.async {
                let directory: [String] = ["Game","\(gameIdForStorage)"]
                
                let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "round\(Int(round.roundNum))", directory: directory, image: UIImage(data: memeData)!)
                
                
                let cardCeasar = CardCeasarJSONModel(playerId: playerId, round: Int(round.roundNum), cardDBurl: roundDic["cardDBUrl"] as! String, imageStorageLocation: filePath)
                round.cardCeasar = cardCeasar
                completeHandler(round)
            }
        }
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
            
            let cardNormal = CardNormal(bottomText: thisCardDic["bottomText"] as! String, didWin: didWin, playerId: playerId, round: Int(round.roundNum), topText: thisCardDic["topText"] as! String, context: GameStack.sharedInstance.stack.context)
            addPlayerLoveToCardNormal(cardNormal: cardNormal, loveDic: thisCardDic["playerlove"] as! [String])
            round.addToCardnormal(cardNormal)
        }
    }
    
    private static func addCardNormalToRoundJSONModel(round: RoundJSONModel, cardDic: [String:Any]){
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
            
            let cardNormal = CardNormalJSONModel(bottomText: thisCardDic["bottomText"] as! String, didWin: didWin, playerId: playerId, round: Int(round.roundNum), topText: thisCardDic["topText"] as! String)
            addPlayerLoveToCardNormalJSONModel(cardNormal: cardNormal, loveDic: thisCardDic["playerlove"] as! [String])
            round.cardNormal.append(cardNormal)
        }
    }
    
    private static func addPlayerLoveToCardNormal(cardNormal: CardNormal, loveDic: [String]){
        for playerId in loveDic {
            let playerLove = PlayerLove(playerId: playerId, context: GameStack.sharedInstance.stack.context)
            cardNormal.addToPlayerlove(playerLove)
        }
    }
    private static func addPlayerLoveToCardNormalJSONModel(cardNormal: CardNormalJSONModel, loveDic: [String]){
        for playerId in loveDic {
            cardNormal.playerLove.append(PlayerLoveJSONModel(playerId: playerId))
        }
    }
}
