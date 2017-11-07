//
//  GameJSONModel.swift
//  Mememe
//
//  Created by Duy Le on 11/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class GameJSONModel{
    var createdDate: Date!
    var gameId: String!
    var rounds = [RoundJSONModel]()
    var model: MememeDBObjectModel!
    var player = [PlayerJSONModel]()
    var winCounter = [WinCounterJSONModel]()
    
    init(createdDate: Date!, gameId: String!, model: MememeDBObjectModel){
        self.createdDate = createdDate
        self.gameId = gameId
        self.model = model
    }
}
