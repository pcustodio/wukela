//
//  OnboardingViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 18/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData


class OnboardingViewController: UIViewController {
    
    var newsLoader = NewsLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        turnOnAll()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("viewDidAppear")
        
        //check for internet availability
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            newsLoader.getJson()
            newsLoader.storeNews()
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Connection Error", message: "Please check if your internet connection is active.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler:{(action:UIAlertAction!) in
                print("Action")
                if Reachability.isConnectedToNetwork(){
                    self.viewDidAppear(animated)
                } else{
                    self.viewDidAppear(animated)
                }
            }))
            self.present(alert, animated: true)
        }

    }

    @IBAction func endSetup(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        UIApplication.shared.windows.first?.rootViewController = mainVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
//        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
//        self.present(mainVC, animated: true, completion: nil)
        self.show(mainVC, sender: .none)
    
    }
    
//MARK: - Turn on all Topics
       
   func turnOnAll() {
       
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       let context = appDelegate.persistentContainer.viewContext
       let entity = NSEntityDescription.entity(forEntityName: "ActiveTopics", in: context)

       let categories = ["Sociedade",
                 "Desporto",
                 "Economia e Negócios",
                 "Política",
                 "Cultura",
                 "Ciência e Tecnologia",
                 "Opinião"]

       for category in categories {
         let newUser = NSManagedObject(entity: entity!, insertInto: context)
         newUser.setValue(category, forKey: "isActiveTopic")
       }

       do {
         try context.save()
       } catch {
         print("Failed saving")
       }

   }

    
}
