//
//  MyCoreData+CoreDataClass.swift
//  
//
//  Created by Duy Le on 9/28/17.
//
//

import Foundation
import CoreData

@objc(MyCoreData)
public class MyCoreData: NSManagedObject {
    convenience init(imageData: Data, laughes: Int, madeCeasar: Int, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "MyCoreData", in: context){
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData as NSData
            self.laughes = Int16(laughes)
            self.madeCeasar = Int16(madeCeasar)
        }
        else {
            fatalError("unable to find CardCeasar Entity name")
        }
    }
}
