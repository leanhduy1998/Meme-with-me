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
        inGameRef.child(leaderId).child("normalCards").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : [String:Any]]
            if postDict?.count == self.playersInGame.count {
                if self.playerJudging == MyPlayerData.id {
                    DispatchQueue.main.async {
                        self.AddEditJudgeMemeBtn.isEnabled = true
                    }
                }
            }
        })
    }
}
