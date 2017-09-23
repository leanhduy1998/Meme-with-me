//
//  CardNormal+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 8/15/17.
//
//

import Foundation
import CoreData


extension CardNormal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardNormal> {
        return NSFetchRequest<CardNormal>(entityName: "CardNormal")
    }

    @NSManaged public var bottomText: String?
    @NSManaged public var didWin: Bool
    @NSManaged public var playerId: String?
    @NSManaged public var round: Int16
    @NSManaged public var topText: String?
    @NSManaged public var currentround: Round?
    @NSManaged public var playerlove: NSSet?

}

// MARK: Generated accessors for playerlove
extension CardNormal {

    @objc(addPlayerloveObject:)
    @NSManaged public func addToPlayerlove(_ value: PlayerLove)

    @objc(removePlayerloveObject:)
    @NSManaged public func removeFromPlayerlove(_ value: PlayerLove)

    @objc(addPlayerlove:)
    @NSManaged public func addToPlayerlove(_ values: NSSet)

    @objc(removePlayerlove:)
    @NSManaged public func removeFromPlayerlove(_ values: NSSet)

}
