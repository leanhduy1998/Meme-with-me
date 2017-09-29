//
//  MyDataStack.swift
//  Mememe
//
//  Created by Duy Le on 9/28/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData

class MyDataStack{
    static let sharedInstance = GameStack()
    var stack = CoreDataStack(modelName: "GameModel")!
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    func saveContext(completeHandler: @escaping ()-> Void){
        do {
            try stack.saveContext()
        }
        catch ((let error)){
            fatalError(error.localizedDescription)
        }
        completeHandler()
    }
    
    func initializeFetchedResultsController() {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "MyCoreData")
        fr.sortDescriptors = [NSSortDescriptor(key: "laughes", ascending: true),
                              NSSortDescriptor(key: "madeCeasar", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}
