//
//  OnboardingMiddleStepViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 28/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit
import CoreData

class OnboardingMiddleStepViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let sourceImages: [UIImage] = [UIImage(named: "sourceImages01")!, UIImage(named: "sourceImages02")!, UIImage(named: "sourceImages03")!, UIImage(named: "sourceImages04")! ]
    
    let sources = ["Jornal Notícias",
                   "O País",
                   "Verdade",
                   "Savana"]
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentlySelected = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.allowsMultipleSelection = true
        nextBtn.isEnabled = false
        nextBtn.setTitleColor(UIColor(white: 1, alpha: 0.2), for: .normal)
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
        nextBtn.setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        
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
                    nextBtn.setTitleColor(UIColor(white: 1, alpha: 0.2), for: .normal)
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
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.sourceImage.image = sourceImages[indexPath.row]
        
        return cell
    }
}

