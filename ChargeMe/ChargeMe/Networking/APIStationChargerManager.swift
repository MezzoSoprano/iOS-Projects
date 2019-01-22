//
//  APIStationChargerManager.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/21/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import Foundation

 class MapChargesTypeURL {
    static var baseURL: String = "https://api.openchargemap.io/v2/poi/?"

    static func getModifiedRequest(coordinates: Coordinates, distance: Double) -> URLRequest {
        let urlString = baseURL + "maxresults=400&latitude=\(coordinates.latitude)&longitude=\(coordinates.longitude)&distance=\(distance)"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        return request
    }
}

final class APIStaionsManager: APIManager {
    
    let sessionConfiguration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    } ()

    init(sessionConfiguration: URLSessionConfiguration) {
        self.sessionConfiguration = sessionConfiguration
    }

    func fetchStationsWith(coordinates: Coordinates, radius: Double, completionHandler: @escaping (APIResult<ChargeStation>) -> Void) {
        
        fetch(request: MapChargesTypeURL.getModifiedRequest(coordinates: coordinates, distance: radius), parse: { (data) -> [ChargeStation]? in
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
