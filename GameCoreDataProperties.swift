//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 8/16/17.
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
    @NSManaged public var playersorder: NSSet?

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

// MARK: Generated accessors for playersorder
extension Game {

    @objc(addPlayersorderObject:)
    @NSManaged public func addToPlayersorder(_ value: PlayerOrderInGame)

    @objc(removePlayersorderObject:)
    @NSManaged public func removeFromPlayersorder(_ value: PlayerOrderInGame)

    @objc(addPlayersorder:)
    @NSManaged public func addToPlayersorder(_ values: NSSet)

    @objc(removePlayersorder:)
    @NSManaged public func removeFromPlayersorder(_ values: NSSet)

}
