//
//  OnboardingMiddleStepViewController.swift
//  wukela
//
//  Created by Paulo Custódio on 28/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class OnboardingMiddleStepViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let data: [UIImage] = [UIImage(named: "sourceImages01")!, UIImage(named: "sourceImages02")!, UIImage(named: "sourceImages03")!, UIImage(named: "sourceImages04")! ]
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SourceCell", for: indexPath) as! SourceCollectionViewCell
        
        cell.sourceImage.layer.cornerRadius = 10.0
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        cell.sourceImage.image = data[indexPath.row]
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemsPerRow: CGFloat = 20
//        let padding: CGFloat = 6
//        let collectionViewWidth: CGFloat = collectionView.frame.width - (padding * itemsPerRow - 1)
//        let widthPerItem: CGFloat = collectionViewWidth / itemsPerRow
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
    
}

