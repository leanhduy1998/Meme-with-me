//
//  MyCoreData+CoreDataProperties.swift
//  
//
//  Created by Duy Le on 9/28/17.
//
//

import Foundation
import CoreData


extension MyCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyCoreData> {
        return NSFetchRequest<MyCoreData>(entityName: "MyCoreData")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var laughes: Int16
    @NSManaged public var madeCeasar: Int16

}
