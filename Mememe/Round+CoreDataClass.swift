//
//  Round+CoreDataClass.swift
//  
//
//  Created by Duy Le on 10/25/17.
//
//

import Foundation
import CoreData

@objc(Round)
public class Round: NSManagedObject {
    convenience init(roundNum: Int, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Round", in: context){
            self.init(entity: ent, insertInto: context)
            self.roundNum = Int16(roundNum)
        }
        else {
            fatalError("unable to find Round Entity name")
        }
    }
}
