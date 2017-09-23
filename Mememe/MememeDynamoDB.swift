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

    static  func insertSampleDataWithCompletionHandler(game: Game, _ completionHandler: @escaping (_ errors: [NSError]?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        var errors: [NSError] = []
        let group: DispatchGroup = DispatchGroup()
        
        let queryHelper = GameDataToJSON(game: game)
        
        let itemForGet: MememeDBObjectModel! = MememeDBObjectModel()
        
        itemForGet._userId = AWSIdentityManager.default().identityId!
        itemForGet._createdDate = queryHelper.getGameCreatedDate() as NSNumber
        itemForGet._game = queryHelper.getGameData()
        

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
    
    static func queryWithPartitionKeyAndSortKeyWithCompletionHandler(timesLoading: Int, _ completionHandler: @escaping (_ response: AWSDynamoDBPaginatedOutput?, _ error: NSError?) -> Void) {
        let objectMapper = AWSDynamoDBObjectMapper.default()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.keyConditionExpression = "#userId = :userId AND #createdDate > :createdDate"
        queryExpression.expressionAttributeNames = [
            "#userId": "userId",
            "#createdDate": "createdDate",
        ]
        
        GetGameData.getCurrentTimeInt(completionHandler: {(currentTime: Int) in
            // only deduct 7 days
            let second = 0
            let minute = 0 * 60
            let hour = 0 * 60 * 60
            let sevenDays = 7 * 60 * 60 * 24
            
            let preferedDate = currentTime - (second + hour + minute + sevenDays) * timesLoading // current - x month
            
            queryExpression.expressionAttributeValues = [
                ":userId": AWSIdentityManager.default().identityId!,
                ":createdDate": preferedDate,
            ]
            objectMapper.query(MememeDBObjectModel.self, expression: queryExpression,completionHandler: {(response: AWSDynamoDBPaginatedOutput?, error: Error?) in
                if response == nil {
                    DispatchQueue.main.async(execute: {
                        completionHandler(response, error as NSError?)
                    })
                    
                }
                else if (response?.items.count)! < 10 * timesLoading && numberOfItemsInQuery != response?.items.count {
                    self.numberOfItemsInQuery = (response?.items.count)!
                    DispatchQueue.main.async {
                        self.queryWithPartitionKeyAndSortKeyWithCompletionHandler(timesLoading: timesLoading + 1, { (results, err) in
                            DispatchQueue.main.async(execute: {
                                self.numberOfItemsInQuery = 0
                                completionHandler(response, err)
                            })
                        })
                    }
                    
                }
                else {
                    self.numberOfItemsInQuery = 0
                    DispatchQueue.main.async(execute: {
                        completionHandler(response, error as NSError?)
                    })
                }
                
                
            })
        
        })
        
        
        
    }
    
}
