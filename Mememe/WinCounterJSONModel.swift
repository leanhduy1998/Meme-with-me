//
//  WinCounterJSONModel.swift
//  Mememe
//
//  Created by Duy Le on 11/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class WinCounterJSONModel{
    var playerId: String!
    var wonNum: Int!
    init(playerId: String, wonNum: Int){
        self.playerId = playerId
        self.wonNum = wonNum
    }
}
