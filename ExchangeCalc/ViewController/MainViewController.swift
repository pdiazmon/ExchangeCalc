//
//  ViewController.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 31/8/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct Conversion: Codable {
    let value: Float
    let text: String
    let timestamp: Int64
}


class MainViewController: UIViewController {

    @IBOutlet weak var FromFlagImg: UIImageView!
    @IBOutlet weak var FromCurrencyBtn: UIButton!
    @IBOutlet weak var ToFlagImg: UIImageView!
    @IBOutlet weak var ToCurrencyBtn: UIButton!
    @IBOutlet weak var AmountText: UITextField!
    @IBOutlet weak var FromLabel: UILabel!
    @IBOutlet weak var ToLabel: UILabel!
    @IBOutlet weak var AmountLabel: UILabel!
    @IBOutlet weak var ResultLabel: UILabel!
    
    var bag = DisposeBag()
    var modelAmount = Variable<String>("")
    var modelFrom = Variable<Symbol>(Symbol(flag: UIImage(named: "flag.png"), symbol: "Select symbol"))
    var modelTo = Variable<Symbol>(Symbol(flag: UIImage(named: "flag.png"), symbol: "Select symbol"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        viewLayout()
        
        getAllSymbols()
        
        rxSetup()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
}

// MARK: Custom methods
extension MainViewController {
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FromSegue") {
            (segue.destination as? SymbolsViewController)?.prepare(sender: self, origin: .from, filter: modelTo.value.symbol)
        }
        else if (segue.identifier == "ToSegue") {
            (segue.destination as? SymbolsViewController)?.prepare(sender: self, origin: .to, filter: modelFrom.value.symbol)
        }
    }
    
    // Callback method for SymbolsViewController transition
    public func symbolReturn(origin: CurrencyOrigin, value: Symbol) {
        switch(origin) {
        case .from:
            modelFrom.value = value
        case .to:
            modelTo.value = value
        }
    }
}


// MARK: RxSwift
extension MainViewController {
  
    func rxSetup() {
        
        // Observe the amount text field
        AmountText.rx.text
            .orEmpty
            .subscribe(onNext: {
                self.modelAmount.value = $0
            })
            .disposed(by: bag)
        
        // Observe the from symbol variable      
        modelFrom.asObservable()
            .subscribe { event in
                self.FromCurrencyBtn.setTitle(event.element!.symbol, for: .normal)
                self.FromFlagImg.image = event.element!.flag        
            }
            .disposed(by: bag)

        // Observe the to symbol variable            
        modelTo.asObservable()
            .subscribe { event in
                self.ToCurrencyBtn.setTitle(event.element!.symbol, for: .normal)
                self.ToFlagImg.image = event.element!.flag 
            }
            .disposed(by: bag)
        
        // If any of the from/to symbol or amount is changed, request the exchange value based on their values
        Observable.combineLatest(modelAmount.asObservable(), modelFrom.asObservable(), modelTo.asObservable())
        { amount, from, to in
            
            getJSONData(sync: .async,
                        modelType: Conversion.self,
                        url: "https://forex.1forge.com/1.0.3/convert",
                        queryItems: [ "from": from.symbol,
                                      "to": to.symbol,
                                      "quantity": amount,
                                      "api_key": "u99mLgK7hizT4NeAAXn52cLkdhhQWGsQ"])
            // completion closure
            { result  in
                // Depending on the result
                switch result {
                case .success(let conversion):
                    self.ResultLabel.text = "\(self.modelAmount.value) \(self.modelFrom.value.symbol!) = \(String(format: "%.2f", conversion.value)) \(self.modelTo.value.symbol!)"
                    
                case .failureError(let error):
                    break
                }
                
            }
            
        }
        .subscribe { value in } // empty subscribe just to activate the observer
        .disposed(by: bag)

    }
}

// MARK: Autolayout
extension MainViewController {
    
    func viewLayout() {
        FromLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: FromLabel, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 0.3, constant: 0),
            NSLayoutConstraint(item: FromLabel, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 0.1, constant: 0)
            ])
        
        FromFlagImg.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: FromFlagImg, attribute: .centerY, relatedBy: .equal, toItem: FromLabel, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: FromFlagImg, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 0.7, constant: 0)
            ])
        
        FromCurrencyBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: FromCurrencyBtn, attribute: .centerY, relatedBy: .equal, toItem: FromLabel, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: FromCurrencyBtn, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: FromCurrencyBtn, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.9, constant: 0)
            ])
        
        ToLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: ToLabel, attribute:.leading , relatedBy: .equal, toItem: FromLabel, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ToLabel, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 0.5, constant: 0)
            ])
        
        ToFlagImg.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: ToFlagImg, attribute: .centerY, relatedBy: .equal, toItem: ToLabel, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ToFlagImg, attribute: .centerX, relatedBy: .equal, toItem: FromFlagImg, attribute: .centerX, multiplier: 1, constant: 0)
            ])
        
        ToCurrencyBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: ToCurrencyBtn, attribute: .centerY, relatedBy: .equal, toItem: ToLabel, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ToCurrencyBtn, attribute: .leading, relatedBy: .equal, toItem: FromCurrencyBtn, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ToCurrencyBtn, attribute: .trailing, relatedBy: .equal, toItem: FromCurrencyBtn, attribute: .trailing, multiplier: 1, constant: 0)
            ])
        
        AmountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: AmountLabel, attribute: .leading, relatedBy: .equal, toItem: FromLabel, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: AmountLabel, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 0.7, constant: 0)
            ])
        
        AmountText.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: AmountText, attribute: .centerY, relatedBy: .equal, toItem: AmountLabel, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: AmountText, attribute: .trailing, relatedBy: .equal, toItem: ToCurrencyBtn, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: AmountText, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 0.8, constant: 0)
            ])
        
        ResultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: ResultLabel, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ResultLabel, attribute: .width, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: ResultLabel, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 1.2, constant: 0)
            ])
    }
}

// MARK: JSON request
extension MainViewController {

    func getAllSymbols() {
        
        getJSONData(sync: .async,
                    modelType: [String].self,
                    url: "https://forex.1forge.com/1.0.3/symbols",
                    queryItems: ["api_key": "u99mLgK7hizT4NeAAXn52cLkdhhQWGsQ"])
        { result in
            
            // Depending on the result
            switch result {
                
            case .success(let symbols):
                
                var tmpSymbols: [Symbol] = []
                
                for symbol in (symbols.map{String($0.dropLast(3))} + symbols.map{String($0.dropFirst(3))}) {
                    
                    
                    if (!tmpSymbols.map { $0.symbol }.contains(symbol)) {
                        let imageUrl = URL(string: "https://raw.githubusercontent.com/transferwise/currency-flags/master/src/flags/\(symbol.lowercased()).png")
                        var img: UIImage? = nil
                        
                        if let data = NSData(contentsOf: imageUrl!) {
                            img = UIImage(data: data as Data)
                        }
                        else {
                            img = UIImage(named: "flag.png")
                        }
                        tmpSymbols.append(Symbol(flag: img, symbol: symbol))
                    }
                }
                
                ExchangeModel.shared.symbols          = tmpSymbols
                ExchangeModel.shared.ObsSymbols.value = tmpSymbols
                
            case .failureError(let error):
                fatalError("error \(error.localizedDescription)")
            }
            
        }
        
    }
}

