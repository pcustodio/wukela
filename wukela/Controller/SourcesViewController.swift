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
    
    let sources = [
        ["Jornal Notícias", "O País", "Verdade"],
        ["Jornal Angola", "Novo Jornal"]
    ]
    var path = 0
    var pathSection = 0
    var pathRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //bkg color
        view.backgroundColor = UIColor(named: "bkColor")
        
        //trigger UITableViewDataSource
        tableView.dataSource = self
        
        //trigger UITableViewDelegate
        tableView.delegate = self
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()
        
        //hide separator line
        //self.tableView.separatorColor = .clear;
        
        //set cell height
        self.tableView.rowHeight = 60;

    }



//MARK: - TableView

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        if section == 0 {
            label.text = "Moçambique"
        } else {
            label.text = "Angola"
        }
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sources.count
    }
    
    //how many rows on TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return nr of messages dynamically
        return sources[section].count
    }
    
    //create our cell
    //indexpath indicates which cell to display on each TableView row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let newsSource = sources[indexPath.section][indexPath.row]
        cell.textLabel?.text = newsSource
        //cell.textLabel?.text = sources[indexPath.row]
        
        //switch
        let swicthView = UISwitch(frame: .zero)
        //swicthView.tag = indexPath.row
        swicthView.tag = indexPath.section * 1000 + indexPath.row
        swicthView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = swicthView
        
        //set switch on/off by checking coredata
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSource")
        let predicate = NSPredicate(format: "isActive == %@", sources[indexPath.section][indexPath.row])
        request.predicate = predicate
        request.fetchLimit = 1
        do{
            let count = try managedContext.count(for: request)
            if(count == 0){
                swicthView.setOn(false, animated: false)
            }
            else{
                swicthView.setOn(true, animated: false)
            }
          }
        catch let error as NSError {
             print("Could not fetch \(error), \(error.userInfo)")
          }

        return cell
        
    }
   
    //MARK: - Toggle
    
    @objc func switchChanged(_ sender: UISwitch!) {
        
        //print(sender.tag)
        path = sender.tag
        pathSection = path/1000
        pathRow = path%10
        //print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if (sender.isOn) {
            turnOn()
            //print("Switched on!")
        } else {
            turnOff()
            //print("Switched off!")
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
        
        user.setValue(sources[pathSection][pathRow], forKeyPath: "isActive")
        
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
        fetchRequest.predicate = NSPredicate(format: "isActive = %@", sources[pathSection][pathRow])
        
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
            
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSource")
        do {
            let result = try managedContext.fetch(fetchRequest)
    
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {

                let retrievedData = data.value(forKey: "isActive") as! String
                print(retrievedData)
            }
        } catch {
            print("Failed")
        }
    }
}
