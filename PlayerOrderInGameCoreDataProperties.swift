//
//  PlayerOrderInGame+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 8/16/17.
//
//

import Foundation
import CoreData


extension PlayerOrderInGame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerOrderInGame> {
        return NSFetchRequest<PlayerOrderInGame>(entityName: "PlayerOrderInGame")
    }

    @NSManaged public var playerId: String?
    @NSManaged public var orderNum: Int16
    @NSManaged public var currentGame: Game?

}
