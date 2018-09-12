//
//  SymbolsViewController.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 2/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum CurrencyOrigin {
  case from
  case to
}

class SymbolsViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    var bag = DisposeBag()
    var origin: CurrencyOrigin!
    var sender: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewLayout()
        rxSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    public func prepare(sender: MainViewController, origin: CurrencyOrigin, filter: String?) {
      self.origin = origin
      self.sender = sender
      ExchangeModel.shared.ObsSymbols.value = ExchangeModel.shared.symbols
        .filter { $0.symbol! != filter! }
        .sorted { $0.symbol < $1.symbol }
    }
    
}

// MARK: RxSwift
extension SymbolsViewController {
  
    func rxSetup() {
        // Bind tableView to its DataSource
        ExchangeModel.shared.ObsSymbols.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "SymbolCell", cellType: SymbolCell.self))
            { row, element, cell in
                cell.render(Symbol(flag: element.flag, symbol: element.symbol))
            }
            .disposed(by: bag)
        
        // tableView select handler
        tableView.rx
            .modelSelected(Symbol.self) // El tipo es Symbol porque en el anterior bind partimos de 'ObsSymbols' que es un array de Symbol
            .subscribe(onNext: { value in
                self.sender.symbolReturn(origin: self.origin, value: value)
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)

    }
}


// MARK: AutoLayout
extension SymbolsViewController {
    
    func viewLayout() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .width, multiplier: 1, constant: 0)
            ])
    }
}
