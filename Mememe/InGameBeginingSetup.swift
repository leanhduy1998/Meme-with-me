//
//  InGameExtension.swift
//  Mememe
//
//  Created by Duy Le on 8/16/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

extension InGameViewController {
    func createBeginingData(){
        let date = Date()
        GetGameData.getCurrentTimeInt { (currentTimeInt) in
            DispatchQueue.main.async {
                self.game = Game(createdDate: date, gameId: self.leaderId + "\(currentTimeInt)", context: GameStack.sharedInstance.stack.context)
                
                for player in self.playersInGame {
                    self.game.addToPlayers(Player(playerName: player.userName, playerId: player.userId!, context: GameStack.sharedInstance.stack.context))
                    
                    let winCounter = WinCounter(playerId: player.userId, wonNum: 0, context: GameStack.sharedInstance.stack.context)
                    self.game.addToWincounter(winCounter)
                }
                
                let round = Round(roundNum: 0, context: GameStack.sharedInstance.stack.context)
                
                let helper = UserFilesHelper()
                helper.getRandomMemeData(completeHandler: { (memeData, memeUrl) in
                    DispatchQueue.main.async {
                        
                        self.playerJudging = self.self.playersInGame[0].userId
                        
                        let ceasarCard = CardCeasar(cardPic: memeData, playerId: self.playerJudging, round: Int(round.roundNum), cardPicUrl: memeUrl, context: GameStack.sharedInstance.stack.context)
                        
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
}
