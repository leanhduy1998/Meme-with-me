//
//  InGameLeaveRoom.swift
//  Mememe
//
//  Created by Duy Le on 10/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import Firebase

extension InGameViewController{
    func leaveRoom(action: UIAlertAction){
        stopPlayers()
        inGameRef.removeAllObservers()
        chatHelper.removeChatObserver()
        if(playersInGame.count == 1){
            InGameHelper.removeYourInGameRoom()
            self.chatHelper.removeChatRoom(id: game.gameId!)
            self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
        }
        else {
            for player in playersInGame {
                if player.userId == MyPlayerData.id {
                    continue
                }
                InGameHelper.updateLeaderId(newLeaderId: player.userId, gameId: game.gameId!, completionHandler: {
                    
                    DispatchQueue.main.async {
                        InGameHelper.removeYourselfFromGame(gameId: self.game.gameId!, completionHandler: {
                            DispatchQueue.main.async {
                                self.inGameRef.child(self.game.gameId!).child("playerOrderInGame").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                                    let playerId = snapshot.value as? String
                                    DispatchQueue.main.async {
                                        self.inGameRef.child(self.game.gameId!).child("playerOrderInGame").setValue(playerId, withCompletionBlock: { (error, reference) in
                                            DispatchQueue.main.async {
                                                InGameHelper.removeYourInGameRoom()
                                                self.leftRoom = true
                                                
                                                self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
                break
            }
            
        }
    }
}
