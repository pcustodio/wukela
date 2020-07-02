//
//  CatViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 09/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class TopicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [NSLocalizedString("Sociedade", comment: ""),
                      NSLocalizedString("Desporto", comment: ""),
                      NSLocalizedString("EconomiaNegócios", comment: ""),
                      NSLocalizedString("Política", comment: ""),
                      NSLocalizedString("CulturaEntretenimento", comment: ""),
                      NSLocalizedString("CiênciaTecnologia", comment: ""),
                      NSLocalizedString("Opinião", comment: "")]
    
    var path = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //sort categories
        categories = categories.sorted {$0 < $1}
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //hide separator line
        self.tableView.separatorColor = .clear
        
        //set cell height
        self.tableView.rowHeight = 60
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()

        //reload table
        tableView.reloadData()
        
        //change navigation bar color
        UINavigationBar.appearance().barTintColor = UIColor(named: "subBkColor")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //implement the refresh dismisser
        TabTransitionMediator.instance.sendTabDismissed(modelChanged: true)
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
//MARK: - Tableview
    
    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    //create our cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        
        //check coredata for active topics and set checkmark
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveTopics")
        do {
            let result = try managedContext.fetch(fetchRequest)
    
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {

                let retrievedData = data.value(forKey: "isActiveTopic") as! String
                if retrievedData == categories[indexPath.row] {
                    cell.accessoryType = .checkmark
                }
            }
        } catch {
            print("Failed")
        }
        return cell
    }
    
    //cell was tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //will print cell that was tapped on
        //print(indexPath.row)

        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        path = indexPath.row
        
        //if row has a check mark turn on Coredata, else turn it off
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            turnOffTopic()
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            print("turningff")
        } else {
            turnOnTopic()
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            print("turningon")
        }
    }
    
    
//MARK: - Turn on Topic in CoreData
    
    func turnOnTopic() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "ActiveTopics", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        
        user.setValue(categories[path], forKeyPath: "isActiveTopic")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
//MARK: - Turn off Topic in CoreData
    
    func turnOffTopic() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveTopics")
        fetchRequest.predicate = NSPredicate(format: "isActiveTopic = %@", categories[path])
        
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
}
