//
//  Round+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 10/25/17.
//
//

import Foundation
import CoreData


extension Round {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Round> {
        return NSFetchRequest<Round>(entityName: "Round")
    }

    @NSManaged public var roundNum: Int16
    @NSManaged public var cardceasar: CardCeasar?
    @NSManaged public var cardnormal: NSSet?
    @NSManaged public var currentgame: Game?
    @NSManaged public var players: NSSet?

}

// MARK: Generated accessors for cardnormal
extension Round {

    @objc(addCardnormalObject:)
    @NSManaged public func addToCardnormal(_ value: CardNormal)

    @objc(removeCardnormalObject:)
    @NSManaged public func removeFromCardnormal(_ value: CardNormal)

    @objc(addCardnormal:)
    @NSManaged public func addToCardnormal(_ values: NSSet)

    @objc(removeCardnormal:)
    @NSManaged public func removeFromCardnormal(_ values: NSSet)

}

// MARK: Generated accessors for players
extension Round {

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

}
