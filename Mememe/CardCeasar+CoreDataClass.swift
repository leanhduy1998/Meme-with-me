//
//  CardCeasar+CoreDataClass.swift
//  
//
//  Created by Duy Le on 10/21/17.
//
//

import Foundation
import CoreData

@objc(CardCeasar)
public class CardCeasar: NSManagedObject {
    convenience init(playerId: String, round: Int, cardDBurl: String, imageStorageLocation: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "CardCeasar", in: context){
            self.init(entity: ent, insertInto: context)
            self.playerId = playerId
            self.round = Int16(round)
            self.cardDBUrl = cardDBurl
            self.imageStorageLocation = imageStorageLocation
        }
        else {
            fatalError("unable to find CardCeasar Entity name")
        }
    }
}
