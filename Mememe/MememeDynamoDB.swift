//
//  Login.swift
//  Mememe
//
//  Created by Duy Le on 8/21/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AWSCore

import AWSMobileHubHelper
import AWSDynamoDB

class MememeDynamoDB {
    private static var numberOfItemsInQuery = 0

    static  func insertGameWithCompletionHandler(game: Game, _ completionHandler: @escaping (_ gameModel: MememeDBObjectModel,_ errors: [NSError]?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var errors: [NSError] = []
        let group: DispatchGroup = DispatchGroup()
        
        let queryHelper = GameDataToJSON(game: game)
        
        let itemToInsert: MememeDBObjectModel! = MememeDBObjectModel()
        
        itemToInsert._userId = MyPlayerData.id
        itemToInsert._createdDate = queryHelper.getGameCreatedDate() as NSNumber
        itemToInsert._game = queryHelper.getGameData()
        

        group.enter()
        
        objectMapper.save(itemToInsert, completionHandler: {(error: Error?) -> Void in
            if let error = error as NSError? {
                DispatchQueue.main.async(execute: {
                    errors.append(error)
                })
            }
            group.leave()
        })
        
        
        group.notify(queue: DispatchQueue.main, execute: {
            if errors.count > 0 {
                completionHandler(itemToInsert, errors)
            }
            else {
                completionHandler(itemToInsert,nil)
            }
        })
    }
    static func updateGame(itemToUpdate: MememeDBObjectModel, game:Game, completionHandler: @escaping (_ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let queryHelper = GameDataToJSON(game: game)
        
        let itemToUpdate: MememeDBObjectModel! = itemToUpdate
        itemToUpdate._game = queryHelper.getGameData()
        
        objectMapper.save(itemToUpdate, completionHandler: {(error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(error as? NSError)
            })
        })
    }
    static func removeItem(_ item: MememeDBObjectModel, completionHandler: @escaping (_ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        objectMapper.remove(item, completionHandler: {(error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(error as? NSError)
            })
        })
    }
    
    /*
    static func scanWithCompletionHandler(limit: Int, _ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: Error?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = limit as NSNumber
        
        objectMapper.scan(MememeDBObjectModel.self, expression: scanExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            completionHandler(response, error)
        }
    }*/
    
    static func queryWithMyPlayerIdWithCompletionHandler(userId: String, _ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "#userId = :userId"
        queryExpression.expressionAttributeNames = ["#userId": "userId",]
        queryExpression.expressionAttributeValues = [":userId": userId]
        
        objectMapper.query(MememeDBObjectModel.self, expression: queryExpression) { (response: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async(execute: {
                completionHandler(response, error as NSError?)
            })
        }
    }
}
