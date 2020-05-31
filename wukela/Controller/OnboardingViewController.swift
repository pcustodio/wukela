//
//  OnboardingMiddleStepViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 28/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class OnboardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let sourceImages: [UIImage] = [UIImage(named: "sourceImages01")!, UIImage(named: "sourceImages02")!, UIImage(named: "sourceImages03")!, UIImage(named: "sourceImages04")! ]
    
    let sources = ["Jornal Notícias",
                   "O País",
                   "Verdade",
                   "Savana"]
    
    var newsLoader = NewsLoader()
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentlySelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //config collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.allowsMultipleSelection = true
        
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
                mainSyncLabel.text = "A sincronizar notícias"
                mainSyncLabel.textAlignment = .center
                mainSyncLabel.font = UIFont(name: "ProximaNova-Light", size: 25)
                window.addSubview(mainSyncLabel)
                UIView.animate(withDuration: 0.5, animations: { mainSyncLabel.alpha = 1.0 })
                
                //insert sublabel
                let subSyncLabel = UILabel(frame: window.frame)
                subSyncLabel.center = CGPoint(x: mainSyncLabel.center.x, y: mainSyncLabel.center.y + 30)
                subSyncLabel.textColor = UIColor.white
                subSyncLabel.alpha = 0
                subSyncLabel.text = "Por favor aguarde..."
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
        
        //config collection view
        collectionView.alpha = 1.0
        nextBtn.alpha = 1.0
        mainLabel.alpha = 1.0
        subLabel.alpha = 1.0

    }
    
    
//MARK: - End Setup
    
    @IBAction func endSetup(_ sender: UIButton) {
        //move to Main storyboard and reset root view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
        UIApplication.shared.windows.first?.rootViewController = mainVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
//        mainVC.modalTransitionStyle = .crossDissolve
//        mainVC.modalPresentationStyle = .fullScreen
//        mainVC.modalTransitionStyle = .coverVertical
        self.show(mainVC, sender: .none)
    }
    
    
//MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)

        print("selected \([indexPath.row])")
        
        //count selected items
        currentlySelected += 1
//        print("currently selected: \(currentlySelected)")
        
        //set btn enabled
        nextBtn.isEnabled = true
        nextBtn.setTitleColor(UIColor(named: "primaryColor"), for: .normal)
        
        //set Source active in Coredata
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "ActiveSources", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        
        user.setValue(sources[indexPath.row], forKeyPath: "isActiveSource")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                
                //count selected items
                currentlySelected -= 1
//                print("de-selected \([indexPath.row])")
                
                //check if any items are selected and disable if 0
                if currentlySelected == 0 {
                    nextBtn.isEnabled = false
                    nextBtn.setTitleColor(UIColor(named: "lineColor"), for: .normal)
                }
//                print("currently selected: \(currentlySelected)")
                return false
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourceCell", for: indexPath) as! SourceCollectionViewCell
    
        //cell roundiness
        cell.sourceImage.layer.cornerRadius = 10.0
        
        //cell shadow
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 1
        cell.layer.shadowOpacity = 0.6
        cell.layer.masksToBounds = false
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.sourceImage.image = sourceImages[indexPath.row]
        
        return cell
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
}

