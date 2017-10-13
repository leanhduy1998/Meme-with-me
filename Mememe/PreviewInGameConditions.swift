//
//  PreviewInGameConditions.swift
//  Mememe
//
//  Created by Duy Le on 10/13/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

extension PreviewInGameViewController{
    func checkIfMyCardExist(cards: [CardNormal]) -> Bool{
        var myCardExist = false
        for card in cards {
            if card.playerId == MyPlayerData.id {
                myCardExist = true
                break
            }
        }
        return myCardExist
    }
}
