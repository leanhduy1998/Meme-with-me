//
//  InGameExtension.swift
//  Mememe
//
//  Created by Duy Le on 8/16/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension InGameViewController {
    func createBeginingData(){
        let date = Date()
        GetGameData.getCurrentTimeInt { (currentTimeInt) in
            DispatchQueue.main.async {
                let helper = UserFilesHelper()
                self.game = Game(createdDate: date, gameId: self.leaderId + "\(currentTimeInt)", context: GameStack.sharedInstance.stack.context)
                
                for player in self.playersInGame {
                    let image = self.userImagesDic[player.userId]
                    
                    // original playerId have us-east-1/ before it, making it hard to store the images
                    var playerIdForStorage = player.userId!
                    
                    let index = playerIdForStorage.index(playerIdForStorage.startIndex, offsetBy: 10)
                    playerIdForStorage = playerIdForStorage.substring(from: index)
                    
                    let imagePath = FileManagerHelper.insertImageIntoMemory(imageName: playerIdForStorage, image: image!)
                    
                    let playerCore = Player(playerName: player.userName, playerId: player.userId!, userImageLocation: imagePath, context: GameStack.sharedInstance.stack.context)
            
                    self.game.addToPlayers(playerCore)
                    
                    let winCounter = WinCounter(playerId: player.userId, wonNum: 0, context: GameStack.sharedInstance.stack.context)
                    self.game.addToWincounter(winCounter)
                }
                
                let round = Round(roundNum: 0, context: GameStack.sharedInstance.stack.context)
                
                
                helper.getRandomMemeData(completeHandler: { (memeData, memeUrl) in
                    DispatchQueue.main.async {

                        self.playerJudging = self.playersInGame[0].userId
                        
                        let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "\(self.game.gameId!) round \(Int(round.roundNum))", image: UIImage(data: memeData)!)
                        
                        let ceasarCard = CardCeasar(cardPic: memeData, playerId: self.playerJudging, round: Int(round.roundNum), cardPicUrl: filePath, context: GameStack.sharedInstance.stack.context)
                        
                        round.cardceasar = ceasarCard
                        self.game.addToRounds(round)
                        
                        InGameHelper.insertNewGame(memeUrl: memeUrl,playerInRoom: self.playersInGame, gameId: self.game.gameId!)
                        
                    
                        MememeDynamoDB.insertGameWithCompletionHandler(game: self.game, { (gameModel, error) in
                            if error != nil {
                                print(error)
                                return
                            }
                            DispatchQueue.main.async {
                                self.gameDBModel = gameModel
                            }
                        })
                        
                        GameStack.sharedInstance.saveContext(completeHandler: {
                            DispatchQueue.main.async {
                                self.reloadCurrentPlayersIcon()
                                self.reloadPreviewCards()
                                
                                self.addObserverForCardNormals()
                                self.checkIfYourAreJudge()
                                
                                self.chatHelper.removeChatRoom(id: MyPlayerData.id)
                                
                                self.chatHelper.id = self.game.gameId
                                self.chatHelper.initializeChatObserver(controller: self)
                            }
                        })
                    }
                })
            }
        }
    }
    func getBeginingGameFromFirB(completionHandler: @escaping () -> Void){
        let conversion = InGameHelperConversion()
        let inGameRef = Database.database().reference().child("inGame")
        inGameRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let gameIdAndValue = snapshot.value as? [String : Any]
            for (gameId,value) in gameIdAndValue! {
                if(!gameId.contains(self.leaderId)){
                    continue
                }
                
                DispatchQueue.main.async {
                    self.game = Game(createdDate: Date(), gameId: gameId, context: GameStack.sharedInstance.stack.context)
                    let postDict = value as? [String : AnyObject] ?? [:]
                    
                    var roundImageUrl: String!
                    
                    for(key,value) in postDict {
                        switch(key) {
                        case "playerOrderInGame":
                            self.playerJudging = value as? String
                            break
                            
                        case "players":
                            let players = value as? [String : AnyObject] ?? [:]
                            
                            for (playerId,playerStats) in players {
                                var image = self.userImagesDic[playerId]
                                
                                let player = conversion.getPlayerFromDictionary(playerId: playerId, playerData: playerStats as! [String : Any])
                                
                                if(image == nil){
                                    image = UIImage()
                                    let helper = UserFilesHelper()
                                    helper.loadUserProfilePicture(userId: playerId, completeHandler: { (imageData) in
                                        DispatchQueue.main.async {
                                            let image = UIImage(data: imageData)
                                            self.userImagesDic[playerId] = image
                                            self.reloadCurrentPlayersIcon()
                                        }
                                        
                                    })
                                }
                                
                                // original playerId have us-east-1/ before it, making it hard to store the images
                                var playerIdForStorage = playerId
                                
                                let index = playerIdForStorage.index(playerIdForStorage.startIndex, offsetBy: 10)
                                playerIdForStorage = playerIdForStorage.substring(from: index)
                                
                                let filePath = FileManagerHelper.insertImageIntoMemory(imageName: playerIdForStorage, image: image!)
                                
                                player.imageStorageLocation = filePath
                                
                                self.game.addToPlayers(player)
                                
                                let winCounter = WinCounter(playerId: playerId, wonNum: 0, context: GameStack.sharedInstance.stack.context)

                                self.game.addToWincounter(winCounter)
                            }
                            break
                            
                        case "rounds":
                            roundImageUrl = value as? String
                            break
                        case "leaderId":
                            self.leaderId = (value as? String)!
                            break
                            
                        default:
                            break
                        }
                    }
                    let round = Round(roundNum: 0, context: GameStack.sharedInstance.stack.context)
                    
                    
                    let helper = UserFilesHelper()
                    helper.getMemeData(memeUrl: roundImageUrl, completeHandler: { (memeData) in
                        DispatchQueue.main.async {
                            let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "\(self.game.gameId!) round \(Int(round.roundNum))", image: UIImage(data: memeData)!)
                            
            
                            let cardCeasar = CardCeasar(cardPic: memeData, playerId: self.playerJudging, round: 0, cardPicUrl: filePath, context: GameStack.sharedInstance.stack.context)
                            round.cardceasar = cardCeasar
                            self.game.addToRounds(round)
                            
                            GameStack.sharedInstance.saveContext(completeHandler: {
                                completionHandler()
                            })
                        }
                    })
                }
            }
            
        })
    }
}
