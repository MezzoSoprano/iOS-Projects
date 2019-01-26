//
//  APIStationChargerManager.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/21/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

 class MapChargesTypeURL {
    static var baseURL: String = "https://api.openchargemap.io/v2/poi/?"

    static func getModifiedRequest(coordinates: Coordinates, distance: Double) -> URLRequest {
        let urlString = baseURL + "maxresults=1000&distanceunit=KM&latitude=\(coordinates.latitude)&longitude=\(coordinates.longitude)&distance=\(distance)"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        return request
    }
}

final class APIStaionsManager: APIManager {
    
    var viewController: MainViewController
    
    let sessionConfiguration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    } ()

    init(sessionConfiguration: URLSessionConfiguration, viewController: MainViewController) {
        self.sessionConfiguration = sessionConfiguration
        self.viewController = viewController
    }

    func fetchStationsWith(coordinates: Coordinates, radius: Double, sender: AnyObject?, completionHandler: @escaping (APIResult<ChargeStation>) -> Void) {
        
        fetch(request: MapChargesTypeURL.getModifiedRequest(coordinates: coordinates, distance: radius), sender: sender, parse: { (data) -> [ChargeStation]? in
            do {
                            //here dataResponse received from a network request
                let decoder = JSONDecoder()
                let models = try decoder.decode([ChargeStation].self, from: data) //Decode JSON Response Data
                            return models
                            } catch let parsingError {
                                print("Error", parsingError)
                                return nil
                            }
        }, completionHandler: completionHandler)
    }
}
