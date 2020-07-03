//
//  OnboardingMiddleStepViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 28/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class OnboardingTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
}

class OnboardingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var headliner: UILabel!
    @IBOutlet weak var subliner: UILabel!

    let countries = [NSLocalizedString("Algeria", comment: ""),
                     NSLocalizedString("Angola", comment: ""),
                     NSLocalizedString("Botswana", comment: ""),
                     NSLocalizedString("Burkina Faso", comment: ""),
                     NSLocalizedString("Cameroon", comment: ""),
                     NSLocalizedString("Cape Verde", comment: ""),
                     NSLocalizedString("Congo", comment: ""),
                     NSLocalizedString("Egypt", comment: ""),
                     NSLocalizedString("Ethiopia", comment: ""),
                     NSLocalizedString("Ghana", comment: ""),
                     NSLocalizedString("Côte d'Ivoire", comment: ""),
                     NSLocalizedString("Kenya", comment: ""),
                     NSLocalizedString("Lybia", comment: ""),
                     NSLocalizedString("Morocco", comment: ""),
                     NSLocalizedString("Mozambique", comment: ""),
                     NSLocalizedString("Nigeria", comment: ""),
                     NSLocalizedString("South Africa", comment: ""),
                     NSLocalizedString("Tanzania", comment: ""),
                     NSLocalizedString("Tunisia", comment: ""),
                     NSLocalizedString("Uganda", comment: "")]

    
    var newsLoader = NewsLoader()
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    var currentlySelected = 0
    var selectedSources = [String]()
    var sourceCount = 0
    var selectedCountryCount = 0
    var checkmarks = [Int : Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        
        //hide separator line
        tableView.separatorColor = .clear
        
        //set cell height
        tableView.rowHeight = 80
        
        //remove extraneous empty cells
        tableView.tableFooterView = UIView()
        
        //set button
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(UIColor(named: "lineColor"), for: .normal)
        
        //activate all topics
        turnOnAllTopics()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("viewDidAppear")
        
        //check for internet availability
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if let window = view.window {
                
                //insert background
                let subView = UIView(frame: window.frame)
                subView.backgroundColor = UIColor(named: "bkColor")
                window.addSubview(subView)

                //insert activity indicator
                let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
                actInd.frame = CGRect(x: window.center.x - 20, y: window.center.y - 60, width: 40.0, height: 40.0);
                actInd.hidesWhenStopped = true
                actInd.style =
                    UIActivityIndicatorView.Style.large
                actInd.color = UIColor(named: "loaderFirst")
                actInd.alpha = 0
                window.addSubview(actInd)
                actInd.startAnimating()
                UIView.animate(withDuration: 0.5, animations: { actInd.alpha = 1.0 })
                
                //insert label
                let mainSyncLabel = UILabel(frame: window.frame)
                mainSyncLabel.center = CGPoint(x: actInd.center.x, y: actInd.center.y + 60)
                mainSyncLabel.textColor = UIColor(named: "textColor")
                mainSyncLabel.alpha = 0
                mainSyncLabel.text = NSLocalizedString("Getting started", comment: "")
                mainSyncLabel.textAlignment = .center
                mainSyncLabel.font = UIFont(name: "ProximaNova-Light", size: 25)
                window.addSubview(mainSyncLabel)
                UIView.animate(withDuration: 0.5, animations: { mainSyncLabel.alpha = 1.0 })
                
                //insert sublabel
                let subSyncLabel = UILabel(frame: window.frame)
                subSyncLabel.center = CGPoint(x: mainSyncLabel.center.x, y: mainSyncLabel.center.y + 30)
                subSyncLabel.textColor = UIColor.white
                subSyncLabel.alpha = 0
                subSyncLabel.text = NSLocalizedString("Wait", comment: "")
                subSyncLabel.textAlignment = .center
                subSyncLabel.font = UIFont(name: "ProximaNova-Bold", size: 12)
                subSyncLabel.textColor = UIColor(named: "subtitleColor")
                window.addSubview(subSyncLabel)
                UIView.animate(withDuration: 1.0, animations: { subSyncLabel.alpha = 1.0 })

                //sync news
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let newsLoader = NewsLoader()
                    newsLoader.getJson()
                    newsLoader.storeNews()
                    
                    UIView.animate(withDuration: 1.0, animations: { subView.alpha = 0.0 }) { (done: Bool) in
                        subView.removeFromSuperview()
                    }
                    UIView.animate(withDuration: 0.5, animations: { actInd.alpha = 0.0 }) { (done: Bool) in
                        actInd.stopAnimating()
                    }
                    UIView.animate(withDuration: 0.5, animations: { mainSyncLabel.alpha = 0.0 }) { (done: Bool) in
                        mainSyncLabel.removeFromSuperview()
                    }
                    UIView.animate(withDuration: 0.5, animations: { subSyncLabel.alpha = 0.0 }) { (done: Bool) in
                        subSyncLabel.removeFromSuperview()
                    }
                }
            }
        } else {
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
        

//        nextBtn.alpha = 1.0
//        mainLabel.alpha = 1.0
//        subLabel.alpha = 1.0

    }
    
    
//MARK: - End Setup
    
    @IBAction func endSetup(_ sender: UIButton) {
        //move to Main storyboard and reset root view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        UIApplication.shared.windows.first?.rootViewController = mainVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        self.show(mainVC, sender: .none)
    }
    
    
//MARK: - Turn on all Topics
        
    func turnOnAllTopics() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ActiveTopics", in: context)

        let categories = [NSLocalizedString("Sociedade", comment: ""),
                          NSLocalizedString("Desporto", comment: ""),
                          NSLocalizedString("EconomiaNegócios", comment: ""),
                          NSLocalizedString("Política", comment: ""),
                          NSLocalizedString("CulturaEntretenimento", comment: ""),
                          NSLocalizedString("CiênciaTecnologia", comment: ""),
                          NSLocalizedString("Opinião", comment: "")]

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

//MARK: - Turn ON country sources
    
    func turnOnCountry() {

        //set Source active in Coredata
        for count in 0...sourceCount {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: "ActiveSources", in: managedContext)!

            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)

                user.setValue(selectedSources[count], forKeyPath: "isActiveSource")
                print(selectedSources[count])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    
//MARK: - Turn OFF country sources
    
    func turnOffCountry() {
        
        for count in 0...sourceCount {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveSources")
            fetchRequest.predicate = NSPredicate(format: "isActiveSource = %@", selectedSources[count])
            
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
    
//MARK: - Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OnboardingTableViewCell
        
        cell.cellTitle?.text = countries[indexPath.row]
        cell.cellImg.layer.cornerRadius = 5.0
        
        if checkmarks[indexPath.row] != nil {
            cell.accessoryType = checkmarks[indexPath.row]! ? .checkmark : .none
        } else {
            checkmarks[indexPath.row] = false
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
        //deselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
        //if selected country is (e.g.) Algeria activate algerian news sources
        switch countries[indexPath.row] {
        case NSLocalizedString("Algeria", comment: ""):
            selectedSources = ["Algérie 360", "Echorouk", "El Khabar", "Observ'Algérie"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Angola", comment: ""):
            selectedSources = ["Folha 8", "Jornal de Angola", "Novo Jornal", "O País (Angola)"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Botswana", comment: ""):
            selectedSources = ["Mmegi", "The Midweek Sun", "The Voice"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Burkina Faso", comment: ""):
            selectedSources = ["Burkina 24", "Le Faso", "Sidwaya"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Cameroon", comment: ""):
            selectedSources = ["Actu Cameroun", "Cameroon Online", "Cameroon Tribune", "Journal du Cameroun"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Cape Verde", comment: ""):
            selectedSources = ["A Nação", "A Semana", "Expresso das Ilhas"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Congo", comment: ""):
            selectedSources = ["7sur7", "Actualite", "Voice of Congo"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Côte d'Ivoire", comment: ""):
            selectedSources = ["Agence Ivoirienne de Presse", "Fratmat", "Linfodrome"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Egypt", comment: ""):
            selectedSources = ["Akhbar El Yom", "Al-Ahram", "Al Wafd", "Egypt Today", "El Balad", "Youm7"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Ethiopia", comment: ""):
            selectedSources = ["Nazret", "The Reporter", "Zehabesha"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Ghana", comment: ""):
            selectedSources = ["Daily Graphic", "Daily Guide", "Ghana News Agency", "Ghanian Times", "Modern Ghana", "The Daily Statesman"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Kenya", comment: ""):
            selectedSources = ["Business Today", "Daily Nation", "Kenya News Agency", "Nairobi Wire", "Standard", "Tuko"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Lybia", comment: ""):
            selectedSources = ["akhbarlibya24", "Al Marsad", "Al Mukhtar Al Arabi‎", "Al-Wasat", "Lybia Observer"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Morocco", comment: ""):
            selectedSources = ["Akhbarona", "Alyaoum 24", "Hespress", "Hiba Press", "Le 360"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Mozambique", comment: ""):
            selectedSources = ["Jornal Notícias", "O País", "Verdade"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Nigeria", comment: ""):
            selectedSources = ["The Guardian", "Punch", "The Nation", "Vanguard"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("South Africa", comment: ""):
            selectedSources = ["Citizen", "Herald", "Isolezwe", "Mail & Guardian", "Sowetan", "Times"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Tanzania", comment: ""):
            selectedSources = ["Daily News", "Mtanzania", "The Citizen"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Tunisia", comment: ""):
            selectedSources = ["Assarih", "Essada", "Nawaat", "Tuniscope", "Tunisien"]
            sourceCount = selectedSources.count - 1
        case NSLocalizedString("Uganda", comment: ""):
            selectedSources = ["Daily Monitor", "New Vision", "The Observer"]
            sourceCount = selectedSources.count - 1
        default:
            sourceCount = 0
        }
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                checkmarks[indexPath.row] = false
                turnOffCountry()
                selectedCountryCount -= 1
            } else {
                cell.accessoryType = .checkmark
                checkmarks[indexPath.row] = true
                turnOnCountry()
                selectedCountryCount += 1
            }
        }
        
        //print(selectedSources)
        //print(countries[indexPath.row])
        //print(selectedSources.count)
        
        //disable or enable Start btn
        if selectedCountryCount == 0 {
            nextBtn.isEnabled = false
            nextBtn.setTitleColor(UIColor(named: "lineColor"), for: .normal)
        } else {
            nextBtn.isEnabled = true
            nextBtn.setTitleColor(UIColor(named: "primaryColor"), for: .normal)
        }
    }
}


