//
//  Common.swift
//  ExchangeCalc
//
//  Created by Pedro L. Diaz Montilla on 2/9/18.
//  Copyright © 2018 Pedro L. Diaz Montilla. All rights reserved.
//

import Foundation
import RxSwift



// getJSONData function completion closure receives a Result value as parameter telling it
// how was the JSON request: successfull or failed
public enum Result<Value> {
    case success(Value) // when successfull, also get the data retrieved
    case failureError(Error) // when failed, also get an exception error
}

public enum SyncMode {
    case sync
    case async
}

public func getJSONData<Type: Decodable>(sync: SyncMode, url: String, queryItems: [String: String], completion: ((Result<Type>) -> Type)?) {
    
    // Compose the URL components
    let _url             = URL(string: url)
    var urlComponents    = URLComponents()
    
    guard let urlp = _url else {
        fatalError("Could not create URL parameter")
    }
    
    urlComponents.scheme = urlp.scheme
    urlComponents.host   = urlp.host
    urlComponents.path   = urlp.path
    
    var queryItemsArray: [URLQueryItem] = []
    for item in queryItems {
        let qi = URLQueryItem(name: item.key, value: item.value)
        queryItemsArray = queryItemsArray + [qi]
    }
    urlComponents.queryItems = queryItemsArray
    
    guard let url = urlComponents.url else {
        fatalError("Could not create URL from components")
    }
    
    // Compose the request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // Compose the session
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    // Execute the request, also giving a completion closure to be executed after the request response
    // completion closure parameters:
    // - responseData: Data?
    // - response: URLResponse?
    // - responseError: Error?
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
        
        // Execute all asynchronously in the main queue
        let executeClosure = {
            // If we have received an error ...
            // if not, responseError should be nil
            if let error = responseError {
                _ = completion?(.failureError(error))
            }
                // If we have received data ...
                // if not, responseData should be nil
            else if let jsonData = responseData {
                let decoder = JSONDecoder()
                
                do {
                    let myData = try decoder.decode(Type.self, from: jsonData)
                    _ = completion?(.success(myData))
                }
                catch {
                    _ = completion?(.failureError(error))
                }
            }
                // If no error received, neither responseData received, something went wrong
            else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                _ = completion?(.failureError(error))
            }
        }
        
        switch sync {
        case .sync:
            executeClosure()
        case .async:
            DispatchQueue.main.async { executeClosure() }
        }
        
        
    }
    
    task.resume()
}

