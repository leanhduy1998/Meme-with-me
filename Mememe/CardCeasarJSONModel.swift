//
//  CardCeasarJSONModel.swift
//  Mememe
//
//  Created by Duy Le on 11/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class CardCeasarJSONModel{
    var playerId: String!
    var round:Int!
    var cardDBurl: String!
    var imageStorageLocation: String!
    
    init(playerId: String, round: Int, cardDBurl: String!, imageStorageLocation: String!){
        self.playerId = playerId
        self.round = round
        self.cardDBurl = cardDBurl
        self.imageStorageLocation = imageStorageLocation
    }
}
