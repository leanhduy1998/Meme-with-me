//
//  MyCoreData+CoreDataClass.swift
//  
//
//  Created by Duy Le on 10/21/17.
//
//

import Foundation
import CoreData

@objc(MyCoreData)
public class MyCoreData: NSManagedObject {
    convenience init(imageStorageLocation: String, laughes: Int, madeCeasar: Int, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "MyCoreData", in: context){
            self.init(entity: ent, insertInto: context)
            self.imageStorageLocation = imageStorageLocation
            self.laughes = Int16(laughes)
            self.madeCeasar = Int16(madeCeasar)
        }
        else {
            fatalError("unable to find CardCeasar Entity name")
        }
    }
}
