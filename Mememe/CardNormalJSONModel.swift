//
//  CardNormalJSONModel.swift
//  Mememe
//
//  Created by Duy Le on 11/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class CardNormalJSONModel{
    var bottomText: String!
    var didWin: Bool!
    var playerId: String!
    var round: Int!
    var topText: String!
    var playerLove: 
    
    init(bottomText: String, didWin: Bool, playerId: String, round: Int, topText: String){
        self.bottomText = bottomText
        self.didWin = didWin
        self.playerId = playerId
        self.round = round
        self.topText = topText
    }
}
