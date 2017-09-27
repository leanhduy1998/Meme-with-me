//
//  GameStack.swift
//  Mememe
//
//  Created by Duy Le on 9/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import CoreData

class GameStack{
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
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Game")
        fr.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true),
                              NSSortDescriptor(key: "gameId", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}
