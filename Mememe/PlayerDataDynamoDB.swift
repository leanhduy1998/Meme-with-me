//
//  PlayerDataDynamoDB.swift
//  Mememe
//
//  Created by Duy Le on 8/26/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AWSCore

import AWSMobileHubHelper
import AWSDynamoDB

class PlayerDataDynamoDB {
    
    static  func insertMyUserDataWithCompletionHandler(_ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
    
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var errors: [NSError] = []
        let group: DispatchGroup = DispatchGroup()

        
        let itemForGet: PlayerDataDBObjectModel! = PlayerDataDBObjectModel()
        
        itemForGet._userId = AWSIdentityManager.default().identityId!
        itemForGet._name = MyPlayerData.name
        
        group.enter()
        
        objectMapper.save(itemForGet, completionHandler: {(error: Error?) -> Void in
            if let error = error as NSError? {
                DispatchQueue.main.async(execute: {
                    errors.append(error)
                })
            }
            group.leave()
        })
        
        
        group.notify(queue: DispatchQueue.main, execute: {
            if errors.count > 0 {
                completionHandler(errors)
            }
            else {
                completionHandler(nil)
            }
        })
    }
    
    
    static func queryWithPartitionKeyWithCompletionHandler(userId: String, _ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId]
        
        objectMapper.query(PlayerDataDBObjectModel.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as NSError?)
            })
        }
    }
    
    static func updateItem(newName: String, newImageUrl: String, _ item: AWSDynamoDBObjectModel, completionHandler: @escaping (_ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToUpdate: PlayerDataDBObjectModel = item as! PlayerDataDBObjectModel
        
        itemToUpdate._name = newName
        
        objectMapper.save(itemToUpdate, completionHandler: {(error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(error as NSError?)
            })
        })
    }
    
}

