//
//  Game+CoreDataClass.swift
//
//
//  Created by Duy Le on 8/16/17.
//
//

import Foundation
import CoreData

@objc(Game)
public class Game: NSManagedObject {
    convenience init(createdDate: Date, gameId: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Game", in: context){
            self.init(entity: ent, insertInto: context)
            self.createdDate = createdDate as NSDate
            self.gameId = gameId
        }
        else {
            fatalError("unable to find Game Entity name")
        }
    }
    convenience init(context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Game", in: context){
            self.init(entity: ent, insertInto: context)
            self.createdDate = Date() as NSDate
            self.gameId = ""
        }
        else {
            fatalError("unable to find Game Entity name")
        }
    }
}

