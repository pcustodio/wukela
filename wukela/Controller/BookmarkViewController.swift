//
//  BookmarkViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class BookmarkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        retrieveData()

    }
    
    //MARK: - Retrieve CoreData
    
    func retrieveData() {
        
        print("retrieving data")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")

        do {
            let result = try managedContext.fetch(fetchRequest)
            
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                print(data.value(forKeyPath: "headlineMarked") as! String)

    
            }
        } catch {
            print("Failed")
        }
    }
    
}
