//
//  APIManager.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/20/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

typealias JSONTask = URLSessionDataTask
typealias JSONCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void

enum APIResult<T> {
    case Success([T])
    case Failure(Error)
}

protocol APIManager {
    
    var sessionConfiguration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask
    func fetch<T: Codable>(request: URLRequest, parse: @escaping (Data) -> [T]?, completionHandler: @escaping (APIResult<T>) -> Void)
}

extension APIManager {
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask {
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
                ]
                let error = NSError(domain: NetworkingErrorDomain, code: 100, userInfo: userInfo)
                
                completionHandler(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completionHandler(nil, HTTPResponse, error)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    completionHandler(data, HTTPResponse, nil)
                default:
                    print("We have got response status \(HTTPResponse.statusCode)")
                }
            }
        }
        return dataTask
    }
    
    func fetch<T>(request: URLRequest, parse: @escaping (Data) -> [T]?, completionHandler: @escaping (APIResult<T>) -> Void) {
        
        let dataTask = JSONTaskWith(request: request) { (data, response, error) in
            
            DispatchQueue.main.async(execute: {
                guard let dataTemp = data else {
                    if let error = error {
                        completionHandler(.Failure(error))
                    }
                    return
                }
                
                if let value = parse(dataTemp) {
                    completionHandler(.Success(value))
                } else {
                    let error = NSError(domain: NetworkingErrorDomain, code: 200, userInfo: nil)
                    completionHandler(.Failure(error))
                }
            })
        }
        dataTask.resume()
    }
}



