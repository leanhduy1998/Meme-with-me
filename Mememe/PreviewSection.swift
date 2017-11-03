//
//  PreviewNode.swift
//  Mememe
//
//  Created by Duy Le on 11/2/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class PreviewSection{
    var sectionTitle: String!
    var games = [Game]()
    var fromInt: Int!
    var toInt: Int!
    var changed = false
    
    init(sectionTitle: String, fromInt: Int, toInt: Int){
        self.sectionTitle = sectionTitle
        self.fromInt = fromInt
        self.toInt = toInt
    }
}
