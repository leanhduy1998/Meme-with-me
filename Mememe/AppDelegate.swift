//
//  AppDelegate.swift
//  Mememe
//
//  Created by Duy Le on 7/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import CoreData
import AWSS3

import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var stack = CoreDataStack(modelName: "Model")!
    
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

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AWSMobileClient.sharedInstance.withApplication(application, withURL: url, withSourceApplication: sourceApplication, withAnnotation: annotation)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        return AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print()
        UserOnlineSystem.goOffline()
        if MyPlayerData.id != nil {
            AvailableRoomHelper.deleteMyRoom()
        }
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController: AvailableGamesViewController = storyboard.instantiateViewController(withIdentifier: "AvailableGamesViewController") as! AvailableGamesViewController;
        
        let rootViewController = self.window!.rootViewController as! UINavigationController;
        rootViewController.pushViewController(viewController, animated: true);*/
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if MyPlayerData.id != nil {
            AvailableRoomHelper.deleteMyRoom()
            InGameHelper.removeYourInGameRoom()
        }
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }


}

