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
                
                let helper = UserFilesHelper()
                helper.getRandomMemeData(completeHandler: { (memeData, memeName) in
                    DispatchQueue.main.async {
                        
                        self.playerJudging = self.self.playersInGame[0].userId
                        
                        let ceasarCard = CardCeasar(cardPic: memeData, playerId: self.playerJudging, round: Int(round.roundNum), cardPicUrl: "ceasarUrl", context: GameStack.sharedInstance.stack.context)
                        
                        round.cardceasar = ceasarCard
                        self.game.addToRounds(round)
                        
                        InGameHelper.insertNewGame(memeName: memeName,playerInRoom: self.playersInGame, gameId: self.game.gameId!)
                        
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
