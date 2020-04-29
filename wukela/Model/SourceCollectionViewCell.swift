//
//  SourceCollectionViewCell.swift
//  wukela
//
//  Created by Paulo Custódio on 28/04/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import UIKit

class SourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sourceImage: UIImageView!
    
    //change cell when selected
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(white: 1, alpha: 0.2)
                layer.borderWidth = 1.0
                layer.borderColor = backgroundColor?.cgColor
                layer.cornerRadius = 10.0
            } else {
                backgroundColor = nil
                layer.borderWidth = 0.0
            }
        }
    }
}
