//
//  OnboardingMiddleStepViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 28/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class OnboardingViewController: UIViewController {

    @IBOutlet weak var headliner: UILabel!
    @IBOutlet weak var subliner: UILabel!
    
    let sources = ["Daily Nation",
                   "Punch",
                   "The Times",
                   "O País",
                   "Al Ahram",
                   "Daily Monitor"]
    
    var newsLoader = NewsLoader()
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    var currentlySelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set text
        headliner.text = NSLocalizedString("Headliner", comment: "")
        subliner.text = NSLocalizedString("Subliner", comment: "")
        
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
}

