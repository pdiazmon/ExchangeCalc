//
//  CollectionViewCell.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 16/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var symbolImg: UIImageView!
    @IBOutlet weak var symbolLbl: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutView()
    }
    
}

// MARK: render
extension CollectionViewCell {
    
    func render(_ model: Symbol) {
        self.symbolLbl.text  = model.symbol
        self.symbolImg.image = model.flag
        self.symbolImg.setNeedsDisplay()
    }
}

// MARK: AutoLayout
extension CollectionViewCell {
    
    func layoutView() {
        
        symbolImg.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: symbolImg, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: symbolImg, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10)
            ])
        
        symbolLbl.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: symbolLbl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: symbolLbl, attribute: .top, relatedBy: .equal, toItem: symbolImg, attribute: .bottom, multiplier: 1, constant: 10)
            ])
    }
}
