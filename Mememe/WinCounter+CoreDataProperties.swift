//
//  WinCounter+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 10/13/17.
//
//

import Foundation
import CoreData


extension WinCounter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WinCounter> {
        return NSFetchRequest<WinCounter>(entityName: "WinCounter")
    }

    @NSManaged public var playerId: String?
    @NSManaged public var won: Int16
    @NSManaged public var currentGame: NSSet?

}

// MARK: Generated accessors for currentGame
extension WinCounter {

    @objc(addCurrentGameObject:)
    @NSManaged public func addToCurrentGame(_ value: Game)

    @objc(removeCurrentGameObject:)
    @NSManaged public func removeFromCurrentGame(_ value: Game)

    @objc(addCurrentGame:)
    @NSManaged public func addToCurrentGame(_ values: NSSet)

    @objc(removeCurrentGame:)
    @NSManaged public func removeFromCurrentGame(_ values: NSSet)

}
