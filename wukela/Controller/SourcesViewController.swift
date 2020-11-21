//
//  OptionsViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 23/03/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class SourcesTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!
}

class SourcesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let sources = [
        ["Algérie 360", "Echorouk", "El Khabar", "Observ'Algérie"],
        ["Folha 8", "Jornal de Angola", "Novo Jornal", "O País (Angola)"],
        ["Mmegi", "The Midweek Sun", "The Voice"],
        ["Burkina 24", "Le Faso", "Sidwaya"],
        ["Actu Cameroun", "Cameroon Online", "Cameroon Tribune", "Journal du Cameroun"],
        ["A Nação", "A Semana", "Expresso das Ilhas"],
        ["7sur7", "Actualite", "Voice of Congo"],
        ["Agence Ivoirienne de Presse", "Fratmat", "Linfodrome"],
        ["Akhbar El Yom", "Al-Ahram", "Al Wafd", "Egypt Today", "El Balad", "Youm7"],
        ["Nazret", "The Reporter", "Zehabesha"],
        ["Daily Graphic", "Daily Guide", "Ghana News Agency", "Ghanian Times", "Modern Ghana"],
        ["Business Today", "Daily Nation", "Kenya News Agency", "Nairobi Wire", "Standard", "Tuko"],
        ["akhbarlibya24", "Al Marsad", "Al Mukhtar Al Arabi‎", "Al-Wasat", "Lybia Observer"],
        ["Akhbarona", "Alyaoum 24", "Hespress", "Hiba Press", "Le 360"],
        ["Jornal Notícias", "O País", "Jornal Domingo", "Folha de Maputo", "Club of Mozambique"],
        ["The Guardian", "Punch", "The Nation", "Vanguard"],
        ["Citizen", "Herald", "Isolezwe", "Mail & Guardian", "Sowetan", "Times"],
        ["Daily News", "Mtanzania", "The Citizen"],
        ["Assarih", "Essada", "Nawaat", "Tuniscope", "Tunisien"],
        ["Daily Monitor", "New Vision", "The Observer"]
    ]
    let languages = [
        [NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: "")],
        [NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: "")],
        [NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: "")],
        [NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: "")],
        [NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: "")],
        [NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: "")],
        [NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: "")],
        [NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("PTSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ZLSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("SWSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")],
        [NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: ""), NSLocalizedString("FRSubtitle", comment: ""), NSLocalizedString("ARSubtitle", comment: "")],
        [NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: ""), NSLocalizedString("ENSubtitle", comment: "")]
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
        
        //customise navigation bar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "textColor")!]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProximaNova-Light", size: 38)!]
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "ProximaNova-Bold", size: 14)!]
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.backgroundColor = UIColor(named: "bkColor")
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //check for internet availability
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            let alert = UIAlertController(title: "Connection Error", message: "Please check if your internet connection is active.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try again", style: .default, handler:{(action:UIAlertAction!) in
                print("Action")
                if Reachability.isConnectedToNetwork(){
                    self.viewDidLoad()
                } else{
                    self.viewDidAppear(animated)
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //implement the refresh dismisser
        TabTransitionMediator.instance.sendTabDismissed(modelChanged: true)
    }

//MARK: - TableView

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor(named: "bkColor")

        let label = UILabel()
        label.frame = CGRect.init(x: 20, y: 0, width: headerView.frame.width-10, height: headerView.frame.height+10)

        label.font = UIFont(name: "ProximaNova-Light", size: 20) // my custom font
        label.textColor = UIColor(named: "subtitleColor") // my custom colour
        
        switch section {
        case 0:
            label.text = NSLocalizedString("Algeria", comment: "")
        case 1:
            label.text = NSLocalizedString("Angola", comment: "")
        case 2:
            label.text = NSLocalizedString("Botswana", comment: "")
        case 3:
            label.text = NSLocalizedString("Burkina Faso", comment: "")
        case 4:
            label.text = NSLocalizedString("Cameroon", comment: "")
        case 5:
            label.text = NSLocalizedString("Cape Verde", comment: "")
        case 6:
            label.text = NSLocalizedString("Congo", comment: "")
        case 7:
            label.text = NSLocalizedString("Côte d'Ivoire", comment: "")
        case 8:
            label.text = NSLocalizedString("Egypt", comment: "")
        case 9:
            label.text = NSLocalizedString("Ethiopia", comment: "")
        case 10:
            label.text = NSLocalizedString("Ghana", comment: "")
        case 11:
            label.text = NSLocalizedString("Kenya", comment: "")
        case 12:
            label.text = NSLocalizedString("Lybia", comment: "")
        case 13:
            label.text = NSLocalizedString("Morocco", comment: "")
        case 14:
            label.text = NSLocalizedString("Mozambique", comment: "")
        case 15:
            label.text = NSLocalizedString("Nigeria", comment: "")
        case 16:
            label.text = NSLocalizedString("South Africa", comment: "")
        case 17:
            label.text = NSLocalizedString("Tanzania", comment: "")
        case 18:
            label.text = NSLocalizedString("Tunisia", comment: "")
        default:
            label.text = NSLocalizedString("Uganda", comment: "")
        }
        
        headerView.addSubview(label)
        return headerView

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SourcesTableViewCell

        let newsSource = sources[indexPath.section][indexPath.row]
        let langSource = languages[indexPath.section][indexPath.row]
        cell.cellTitle?.text = newsSource
        cell.cellSubtitle?.text = langSource
        
        //switch
        let swicthView = UISwitch(frame: .zero)
        //swicthView.tag = indexPath.row
        swicthView.tag = indexPath.section * 1000 + indexPath.row
        swicthView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = swicthView
        
        //set switch on/off by checking coredata
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSources")
        let predicate = NSPredicate(format: "isActiveSource == %@", sources[indexPath.section][indexPath.row])
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
    
//MARK: - Turn on Source - CoreData
    
    func turnOn() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "ActiveSources", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        
        user.setValue(sources[pathSection][pathRow], forKeyPath: "isActiveSource")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
//MARK: - Turn off Source
    
    func turnOff() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSources")
        fetchRequest.predicate = NSPredicate(format: "isActiveSource = %@", sources[pathSection][pathRow])
        
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
    
    
//MARK: - Check active source - Coredata
    
    func retrieveActiveSources() {
            
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSources")
        do {
            let result = try managedContext.fetch(fetchRequest)
    
            //Loop over CoreData entities
            for data in result as! [NSManagedObject] {

                let retrievedData = data.value(forKey: "isActiveSource") as! String
                print(retrievedData)
            }
        } catch {
            print("Failed")
        }
    }
}
