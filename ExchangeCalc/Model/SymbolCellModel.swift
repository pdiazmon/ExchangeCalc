//
//  SymbolCellModel.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 2/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import Foundation
import UIKit

class Symbol {
    var flag: UIImage!
    var symbol: String!
    
    init(flag: UIImage?, symbol: String?) {
        self.flag = flag
        self.symbol = symbol
    }
}
