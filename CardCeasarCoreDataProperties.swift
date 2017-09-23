//
//  CardCeasar+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 8/24/17.
//
//

import Foundation
import CoreData


extension CardCeasar {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardCeasar> {
        return NSFetchRequest<CardCeasar>(entityName: "CardCeasar")
    }

    @NSManaged public var cardPic: NSData?
    @NSManaged public var playerId: String?
    @NSManaged public var round: Int16
    @NSManaged public var cardPicUrl: String?
    @NSManaged public var currentround: Round?

}
