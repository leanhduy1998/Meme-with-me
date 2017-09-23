//
//  PlayerLove+CoreDataClass.swift
//  
//
//  Created by Duy Le on 8/14/17.
//
//

import Foundation
import CoreData

@objc(PlayerLove)
public class PlayerLove: NSManagedObject {
    convenience init(playerId: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "PlayerLove", in: context){
            self.init(entity: ent, insertInto: context)
            self.playerId = playerId
        }
        else {
            fatalError("unable to find PlayerLove Entity name")
        }
    }
}
