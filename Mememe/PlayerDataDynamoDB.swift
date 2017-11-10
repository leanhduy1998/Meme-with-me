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
        
        itemForGet._userId = MyPlayerData.id
        itemForGet._name = MyPlayerData.name
        itemForGet._laughes = 0
        itemForGet._madeCeasar = 0
        
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
    
    
    static func updateLaughes(laughes: Int,completionHandler: @escaping (_ error: NSError?) -> Void) {
        queryWithPartitionKeyWithCompletionHandler(userId: MyPlayerData.id) { (results, error) in
            DispatchQueue.main.async {
                if(error == nil){
                    let data = results?.items[0] as? PlayerDataDBObjectModel
                    
                    let currentLaughes = (data?._laughes)! as Int!
                    
                    let objectMapper = AWSDynamoDBObjectMapper.default()
                    let itemToUpdate: PlayerDataDBObjectModel = data!
                    
                    itemToUpdate._laughes = currentLaughes! + laughes as NSNumber
                    
                    objectMapper.save(itemToUpdate, completionHandler: {(error: Error?) in
                        DispatchQueue.main.async(execute: {
                            completionHandler(error as NSError?)
                        })
                    })
                }
            }
        }
    }
    static func updateMadeCeasar(madeCeasar: Int,completionHandler: @escaping (_ error: NSError?) -> Void) {
        queryWithPartitionKeyWithCompletionHandler(userId: MyPlayerData.id) { (results, error) in
            DispatchQueue.main.async {
                if(error == nil){
                    let data = results?.items[0] as? PlayerDataDBObjectModel
                    
                    let currentMadeCeasar = (data?._madeCeasar)! as Int!
                    
                    let objectMapper = AWSDynamoDBObjectMapper.default()
                    let itemToUpdate: PlayerDataDBObjectModel = data!
                    
                    itemToUpdate._madeCeasar = currentMadeCeasar! + madeCeasar as NSNumber
                    
                    objectMapper.save(itemToUpdate, completionHandler: {(error: Error?) in
                        DispatchQueue.main.async(execute: {
                            completionHandler(error as NSError?)
                        })
                    })
                }
            }
        }
    }
    
    static func updateUserName(name: String,completionHandler: @escaping (_ error: NSError?) -> Void) {
        queryWithPartitionKeyWithCompletionHandler(userId: MyPlayerData.id) { (results, error) in
            DispatchQueue.main.async {
                if(error == nil){
                    let data = results?.items[0] as? PlayerDataDBObjectModel
                    
                    let objectMapper = AWSDynamoDBObjectMapper.default()
                    let itemToUpdate: PlayerDataDBObjectModel = data!
                    
                    itemToUpdate._name = name
                    
                    objectMapper.save(itemToUpdate, completionHandler: {(error: Error?) in
                        DispatchQueue.main.async(execute: {
                            completionHandler(error as NSError?)
                        })
                    })
                }
            }
        }
    }
    
    
}

