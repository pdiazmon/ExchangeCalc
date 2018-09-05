//
//  SymbolCell.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 3/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit

class SymbolCell: UITableViewCell {
    
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var symbolTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutView()
    }
}

// MARK: render
extension SymbolCell {
    
    func render(_ model: Symbol) {
        self.symbolTxt.text = model.symbol
        self.flagImg.image = model.flag
        self.flagImg.setNeedsDisplay()
      
        /*
        if let flag = model.flag {
            self.flagImg.image  = flag
        }
        else {
            if let img = ExchangeModel.shared.flagsDict[model.symbol] {
                DispatchQueue.main.async {            
                    self.flagImg.image = img
                    self.flagImg.setNeedsDisplay()            
                }
            }
            else {
                let imageUrl = URL(string: "https://raw.githubusercontent.com/transferwise/currency-flags/master/src/flags/\(model.symbol.lowercased()).png")

                DispatchQueue.global(qos: .userInitiated).async {
                    let imageData = NSData(contentsOf: imageUrl!)
                
                    if let data = imageData {
                        let newImg    = UIImage(data: data as Data)
                        ExchangeModel.shared.flagsDict[model.symbol] = newImg
                
                        DispatchQueue.main.async {
                            self.flagImg.image = newImg
                            self.flagImg.setNeedsDisplay()
                        }
                    }
                }           
            }
        }
        */
    }
}

// MARK: AutoLayout
extension SymbolCell {
  
    func layoutView() {
        
        flagImg.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: flagImg, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: flagImg, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: flagImg, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        
        symbolTxt.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            NSLayoutConstraint(item: symbolTxt, attribute: .leading, relatedBy: .equal, toItem: flagImg, attribute: .trailing, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: symbolTxt, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: symbolTxt, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
    }
}
