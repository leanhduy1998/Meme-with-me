//
//  Player+CoreDataClass.swift
//  
//
//  Created by Duy Le on 10/20/17.
//
//

import Foundation
import CoreData

@objc(Player)
public class Player: NSManagedObject {
    convenience init(playerName: String, playerId: String, userImageLocation: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Player", in: context){
            self.init(entity: ent, insertInto: context)
            self.playerId = playerId
            self.name = playerName
            self.userImageLocation = userImageLocation
        }
        else {
            fatalError("unable to find Player Entity name")
        }
    }
}
