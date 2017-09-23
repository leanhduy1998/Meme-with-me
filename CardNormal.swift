//
//  CardNormal+CoreDataClass.swift
//  
//
//  Created by Duy Le on 8/15/17.
//
//

import Foundation
import CoreData

@objc(CardNormal)
public class CardNormal: NSManagedObject {
    convenience init(bottomText: String, didWin: Bool, playerId: String, round: Int, topText: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "CardNormal", in: context){
            self.init(entity: ent, insertInto: context)
            self.bottomText = bottomText
            self.didWin = didWin
            self.playerId = playerId
            self.topText = topText
            self.round = Int16(round)
        }
        else {
            fatalError("unable to find CardNormal Entity name")
        }
    }
    convenience init(context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "CardNormal", in: context){
            self.init(entity: ent, insertInto: context)
            self.bottomText = ""
            self.didWin = false
            self.playerId = ""
            self.topText = ""
            self.round = Int16(0)
        }
        else {
            fatalError("unable to find CardNormal Entity name")
        }
    }
}
