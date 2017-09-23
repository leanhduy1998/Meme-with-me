//
//  PlayerDataDBObjectModel.swift
//  Mememe
//
//  Created by Duy Le on 8/26/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AWSDynamoDB

class PlayerDataDBObjectModel: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var _userId: String?
    var _name: String?
    
    class func dynamoDBTableName() -> String {
        
        return "mememe-mobilehub-1008058883-PlayerData"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_name" : "name",
        ]
    }
}
