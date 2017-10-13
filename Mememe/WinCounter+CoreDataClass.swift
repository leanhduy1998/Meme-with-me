//
//  WinCounter+CoreDataClass.swift
//  
//
//  Created by Duy Le on 10/13/17.
//
//

import Foundation
import CoreData

@objc(WinCounter)
public class WinCounter: NSManagedObject {
    convenience init(playerId: String, wonNum: Int, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "WinCounter", in: context){
            self.init(entity: ent, insertInto: context)
            self.playerId = playerId
            self.won = Int16(wonNum)
        }
        else {
            fatalError("unable to find WinCounter Entity name")
        }
    }
}
