//
//  RoundJSONModel.swift
//  Mememe
//
//  Created by Duy Le on 11/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class RoundJSONModel{
    var roundNum: Int!
    var players = [PlayerJSONModel]()
    var cardCeasar: CardCeasarJSONModel!
    
    init(roundNum: Int){
        self.roundNum = roundNum
    }
}
