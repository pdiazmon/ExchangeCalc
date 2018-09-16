//
//  SymbolsCollectionViewController.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 16/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "CollectionCell"

enum CurrencyOrigin {
    case from
    case to
}

class SymbolsCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var bag = DisposeBag()
    var origin: CurrencyOrigin!
    var sender: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionView.dataSource = self
        //collectionView.delegate   = self
        
        rxSetup()
        layoutView()
    }
    
    public func prepare(sender: MainViewController, origin: CurrencyOrigin, filter: String?) {
        self.origin = origin
        self.sender = sender
        ExchangeModel.shared.ObsSymbols.value = ExchangeModel.shared.symbols
            .filter { $0.symbol! != filter! }
            .sorted { $0.symbol < $1.symbol }
    }


}
// MARK: - RxSwift
extension SymbolsCollectionViewController {
    
    func rxSetup() {
        
        // Bind collectionView to its DataSource
        ExchangeModel.shared.ObsSymbols.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: CollectionViewCell.self))
            { row, element, cell in
                cell.render(Symbol(flag: element.flag, symbol: element.symbol))
                print("> Render: \(element.symbol!)")
            }
            .disposed(by: bag)
        
        // collectionView select handler
        collectionView.rx
            .modelSelected(Symbol.self) // Type is 'Symbol' because in the previous bind we use 'ObsSymbols' which is a Symbols array
            .subscribe(onNext: { value in
                self.sender.symbolReturn(origin: self.origin, value: value)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
        
    }
}


extension SymbolsCollectionViewController {
    func layoutView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: collectionView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
            ])
    }
}



/*
 // MARK: - DataSource
 extension SymbolsCollectionViewController: UICollectionViewDataSource {
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return ExchangeModel.shared.ObsSymbols.value.count
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
 
 cell.render(ExchangeModel.shared.ObsSymbols.value[indexPath.row])
 
 return cell
 }
 }
 
 // MARK: - Delegate
 extension SymbolsCollectionViewController: UICollectionViewDelegate {
 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 let symbolSelected = ExchangeModel.shared.ObsSymbols.value[indexPath.row]
 
 self.sender.symbolReturn(origin: self.origin, value: symbolSelected)
 self.navigationController?.popViewController(animated: true)
 }
 
 }
 */

