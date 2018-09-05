//
//  Model.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 2/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import Foundation
import RxSwift

class ExchangeModel {
    
    var symbols: [Symbol] = []
    var ObsSymbols: Variable<[Symbol]>
  
    // var flagsDict: [String: UIImage] = [:]
    
    static var shared: ExchangeModel = ExchangeModel()
    
    init() {
        ObsSymbols = Variable(symbols)
    }
}
