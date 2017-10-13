//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 10/13/17.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var createdDate: NSDate?
    @NSManaged public var gameId: String?
    @NSManaged public var players: NSSet?
    @NSManaged public var rounds: NSSet?
    @NSManaged public var wincounter: NSSet?

}

// MARK: Generated accessors for players
extension Game {

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

}

// MARK: Generated accessors for rounds
extension Game {

    @objc(addRoundsObject:)
    @NSManaged public func addToRounds(_ value: Round)

    @objc(removeRoundsObject:)
    @NSManaged public func removeFromRounds(_ value: Round)

    @objc(addRounds:)
    @NSManaged public func addToRounds(_ values: NSSet)

    @objc(removeRounds:)
    @NSManaged public func removeFromRounds(_ values: NSSet)

}

// MARK: Generated accessors for wincounter
extension Game {

    @objc(addWincounterObject:)
    @NSManaged public func addToWincounter(_ value: WinCounter)

    @objc(removeWincounterObject:)
    @NSManaged public func removeFromWincounter(_ value: WinCounter)

    @objc(addWincounter:)
    @NSManaged public func addToWincounter(_ values: NSSet)

    @objc(removeWincounter:)
    @NSManaged public func removeFromWincounter(_ values: NSSet)

}
