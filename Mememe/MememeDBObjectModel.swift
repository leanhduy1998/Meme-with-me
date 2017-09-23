//
//  MemeDBObjectModel.swift
//  Mememe
//
//  Created by Duy Le on 8/22/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AWSDynamoDB

class MememeDBObjectModel: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    var _userId: String?
    var _createdDate: NSNumber?
    var _game: Data?
    
    class func dynamoDBTableName() -> String {
        
        return "mememe-mobilehub-1008058883-Mememe"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_createdDate"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_createdDate" : "createdDate",
            "_game" : "game",
        ]
    }
}
