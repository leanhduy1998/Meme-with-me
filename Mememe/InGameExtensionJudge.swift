//
//  InGameExtensionJudge.swift
//  Mememe
//
//  Created by Duy Le on 9/21/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension InGameViewController {
    func checkIfAllPlayersHaveInsertCard(){
        inGameRef.child(game.gameId!).child("normalCards").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : [String:Any]]
            if postDict?.count == self.playersInGame.count - 1 {
                if self.playerJudging == MyPlayerData.id {
                    DispatchQueue.main.async {
                        self.AddEditJudgeMemeBtn.isEnabled = true
                    }
                }
            }
        })
    }
}
