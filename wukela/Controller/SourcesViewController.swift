//
//  OptionsViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 23/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class SourcesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let sources = ["Jornal Notícias", "O País", "Verdade"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //hide separator line
        self.tableView.separatorColor = .clear;
        
        //set cell height
        self.tableView.rowHeight = 70;

    }



//MARK: - TableView

    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        return 3
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        

        
        cell.textLabel?.text = sources[indexPath.row]
        
        //add switch to cell
        let switchObj = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
        switchObj.isOn = false
        switchObj.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
        cell.accessoryView = switchObj
        
        return cell
        
    }
   
    //MARK: - Toggle
    
    @objc func toggle(_ sender: UISwitch) {
        
        if (sender.isOn) {
            turnOn()
            print("Switched on!")
        } else {
            turnOff()
            print("Switched off!")
        }

        
        retrieveActiveSources()
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //will print cell that was tapped on
        //print(indexPath.row)

        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Create CoreData
    
    func turnOn() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "ActiveSource", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        user.setValue("Jornal Notícias", forKeyPath: "isActive")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func turnOff() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSource")
        fetchRequest.predicate = NSPredicate(format: "isActive = %@", "Jornal Notícias")
        
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
    
    func retrieveActiveSources() {
            
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSource")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {
                
                //check if they are saving
//                print(data.value(forKeyPath: "ptNoted") as! String)
//                print(data.value(forKeyPath: "trNoted") as! String)
//                print(data.value(forKeyPath: "laNoted") as! String)
//                print(data.value(forKeyPath: "dateNoted") as! String)
                
                //retrieved data is stored translation term
                let retrievedData = data.value(forKey: "isActive") as! String
                print(retrievedData)
                
                //if coredata word  matches translated term on screen
                
            }
        } catch {
            print("Failed")
        }
    }
}
