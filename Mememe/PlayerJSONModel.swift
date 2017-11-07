//
//  PlayerJSONModel.swift
//  Mememe
//
//  Created by Duy Le on 11/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class PlayerJSONModel{
    var playerName: String!
    var playerId: String!
    var userImageLocation: String!
    
    init(playerName: String, playerId: String, userImageLocation: String){
        self.playerId = playerId
        self.playerName = playerName
        self.userImageLocation = userImageLocation
    }
}
