//
//  AppDelegate.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData
//import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        //request authorization when app launches
//        requestNotificationAuthorization(application: application)
        
        //background fetch
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        //turn on all topics in coredata if is 1st load
        //        _ = isAppAlreadyLaunchedOnce()
        
        return true
    }
    
    // Support for background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let newsLoader = NewsLoader()
        print("background fetch")
        newsLoader.getJson()
        newsLoader.deleteNews()
        newsLoader.storeNews()
        completionHandler(.newData)
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "wukela")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    //MARK: - Turn on all Topics
    
    //    func turnOnAll() {
    //
    //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //        let context = appDelegate.persistentContainer.viewContext
    //        let entity = NSEntityDescription.entity(forEntityName: "ActiveTopics", in: context)
    //
    //        let categories = ["Sociedade",
    //                  "Desporto",
    //                  "Economia",
    //                  "Política",
    //                  "Cultura e Entretenimento",
    //                  "Ciência e Tecnologia",
    //                  "Opinião"]
    //
    //        for category in categories {
    //          let newUser = NSManagedObject(entity: entity!, insertInto: context)
    //          newUser.setValue(category, forKey: "isActiveTopic")
    //        }
    //
    //        do {
    //          try context.save()
    //        } catch {
    //          print("Failed saving")
    //        }
    //
    //    }
    
}

