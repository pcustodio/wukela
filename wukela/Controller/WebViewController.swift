//
//  WebViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 21/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class WebViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var bookmarkIcon: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    
    var url = ""
    var headline = ""
    
    
    //activity idicator
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //loader
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.isHidden = true
        view.addSubview(activityIndicator)
        
        //webkit
        webView.navigationDelegate = self
        let loadURL = URL (string: url)
        let request = URLRequest(url: loadURL!)
        webView.load(request)
        
        retrieveData()
        print("Current headline is >>> \(headline)")
        
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        retrieveData()
    //    }
    
    //MARK: - Buttons
    
    @IBAction func bookmarkBtn(_ sender: UIBarButtonItem) {
        
        if self.bookmarkIcon.image == UIImage(systemName: "bookmark.fill") {
            deleteData()
            retrieveData()
            
        } else {
            createData()
            retrieveData()
        }
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Loader
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    
    //MARK: - Create CoreData
    
    func createData() {
        
        print("creating data")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Bookmarks", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue(headline, forKeyPath: "headlineMarked")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    //MARK: - Retrieve CoreData
    
    func retrieveData() {
        
        print("retrieving data")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                
                //print(data.value(forKeyPath: "headlineMarked") as! String)
                
                //retrieved data is stored translation term
                let retrievedData = data.value(forKey: "headlineMarked") as! String
                print("I retrieved >> \(retrievedData)")
                
                //if coredata word  matches translated term on screen
                if retrievedData == headline {
                    
                    //It is a Fav change bookmark icon to filled
                    self.bookmarkIcon.image = UIImage(systemName: "bookmark.fill")
                    
                } else {
                    //Not a Fav
                    self.bookmarkIcon.image = UIImage(systemName: "bookmark")
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    //MARK: - Delete CoreData
    
    func deleteData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmarks")
        fetchRequest.predicate = NSPredicate(format: "headlineMarked = %@", headline)
        
        do
        {
            //check if there are any items to delete to prevent crash if nil
            let saved = try managedContext.fetch(fetchRequest)
            let savedData = saved.count
            if savedData <= 0 {
                print("blimey")
            } else {
                let objectToDelete = saved[0] as! NSManagedObject
                managedContext.delete(objectToDelete)
            }
            
            self.bookmarkIcon.image = UIImage(systemName: "bookmark")
            
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
}

