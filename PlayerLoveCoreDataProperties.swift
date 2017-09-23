//
//  PlayerLove+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 8/14/17.
//
//

import Foundation
import CoreData


extension PlayerLove {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerLove> {
        return NSFetchRequest<PlayerLove>(entityName: "PlayerLove")
    }

    @NSManaged public var playerId: String?
    @NSManaged public var cardnormal: CardNormal?

}
