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
        backgroundPlayer.stop()
        removeAllInGameObservers()
        
        if(playersInGame.count <= 1){
            InGameHelper.removeYourInGameRoom()
            self.chatHelper.removeChatRoom(id: game.gameId!)
            self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
        }
        else {
            if MyPlayerData.id != leaderId {
                InGameHelper.removeYourselfFromGame(gameId: self.game.gameId!, completionHandler: {
                    self.performSegue(withIdentifier: "unwindToAvailableGamesViewController", sender: self)
                })
            }
            else{
                var player: PlayerData!
                for p in playersInGame {
                    if p.userId == MyPlayerData.id {
                        continue
                    }
                    else{
                        player = p
                    }
                }
                
                InGameHelper.updateLeaderId(newLeaderId: player.userId, gameId: game.gameId!, completionHandler: {
                        
                    DispatchQueue.main.async {
                        InGameHelper.removeYourselfFromGame(gameId: self.game.gameId!, completionHandler: {
                            DispatchQueue.main.async {
                            self.inGameRef.child(self.game.gameId!).child("playerOrderInGame").setValue(player.userId, withCompletionBlock: { (error, reference) in
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
        }
    }
}
