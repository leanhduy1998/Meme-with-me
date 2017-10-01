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
                    self.game.addToPlayers(Player(laughes: 0, playerName: player.userName, playerId: player.userId!, score: 0, context: GameStack.sharedInstance.stack.context))
                    
                    // might add image data to Player too!
                }
                
                let round = Round(roundNum: 0, context: GameStack.sharedInstance.stack.context)
                
                self.playersInGame = self.playersInGame.shuffled()
                
                var counter = 0
                for player in self.playersInGame {
                    let order = PlayerOrderInGame(orderNum: counter, playerId: player.userId!, context: GameStack.sharedInstance.stack.context)
                    self.game.addToPlayersorder(order)
                    counter = counter + 1
                }
                
                let helper = UserFilesHelper()
                helper.getRandomMemeData(completeHandler: { (memeData, memeName) in
                    DispatchQueue.main.async {
                        let playerOrders = self.game.playersorder?.allObjects as? [PlayerOrderInGame]
                        
                        let ceasarId = self.getCeasarIdForCurrentRound(roundNum: 0)
                        
                        let ceasarCard = CardCeasar(cardPic: memeData, playerId: ceasarId, round: Int(round.roundNum), cardPicUrl: "ceasarUrl", context: GameStack.sharedInstance.stack.context)
                        
                        round.cardceasar = ceasarCard
                        self.game.addToRounds(round)
                        
                        InGameHelper.insertNewGame(memeName: memeName,playerInRoom: self.playersInGame, playerOrder: playerOrders!, gameId: self.game.gameId!)
                        
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
