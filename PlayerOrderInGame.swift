//
//  PlayerOrderInGame+CoreDataClass.swift
//  
//
//  Created by Duy Le on 8/16/17.
//
//

import Foundation
import CoreData

@objc(PlayerOrderInGame)
public class PlayerOrderInGame: NSManagedObject {
    convenience init(orderNum: Int, playerId: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "PlayerOrderInGame", in: context){
            self.init(entity: ent, insertInto: context)
            self.orderNum = Int16(orderNum)
            self.playerId = playerId
        }
        else {
            fatalError("unable to find PlayerOrderInGame Entity name")
        }
    }
}
