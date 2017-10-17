//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 10/14/17.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var name: String?
    @NSManaged public var playerId: String?
    @NSManaged public var userImageData: NSData?
    @NSManaged public var game: Game?

}
