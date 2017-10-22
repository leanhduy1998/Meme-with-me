//
//  CardCeasar+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 10/21/17.
//
//

import Foundation
import CoreData


extension CardCeasar {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardCeasar> {
        return NSFetchRequest<CardCeasar>(entityName: "CardCeasar")
    }

    @NSManaged public var imageStorageLocation: String?
    @NSManaged public var playerId: String?
    @NSManaged public var round: Int16
    @NSManaged public var cardDBUrl: String?
    @NSManaged public var currentround: Round?

}
