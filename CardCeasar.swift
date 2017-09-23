//
//  CardCeasar+CoreDataClass.swift
//  
//
//  Created by Duy Le on 8/24/17.
//
//

import Foundation
import CoreData

@objc(CardCeasar)
public class CardCeasar: NSManagedObject {
    convenience init(cardPic: Data, playerId: String, round: Int, cardPicUrl: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "CardCeasar", in: context){
            self.init(entity: ent, insertInto: context)
            self.cardPic = cardPic as NSData
            self.playerId = playerId
            self.round = Int16(round)
            self.cardPicUrl = cardPicUrl
        }
        else {
            fatalError("unable to find CardCeasar Entity name")
        }
    }
    convenience init(playerId: String, round: Int, cardPicUrl: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "CardCeasar", in: context){
            self.init(entity: ent, insertInto: context)
            self.playerId = playerId
            self.round = Int16(round)
            self.cardPicUrl = cardPicUrl
        }
        else {
            fatalError("unable to find CardCeasar Entity name")
        }
    }
}
