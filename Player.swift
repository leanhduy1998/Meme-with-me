//
//  Player+CoreDataClass.swift
//  
//
//  Created by Duy Le on 9/16/17.
//
//

import Foundation
import CoreData

@objc(Player)
public class Player: NSManagedObject {
    convenience init(laughes: Int,playerName: String, playerId: String, score: Int, userImageData: Data, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Player", in: context){
            self.init(entity: ent, insertInto: context)
            self.laughes = Int16(laughes)
            self.playerId = playerId
            self.score = Int16(score)
            self.name = playerName
            self.userImageData = userImageData as NSData
        }
        else {
            fatalError("unable to find Player Entity name")
        }
    }
    convenience init(laughes: Int, playerName: String, playerId: String, score: Int, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Player", in: context){
            self.init(entity: ent, insertInto: context)
            self.laughes = Int16(laughes)
            self.playerId = playerId
            self.name = playerName
            self.score = Int16(score)
        }
        else {
            fatalError("unable to find Player Entity name")
        }
    }
}
