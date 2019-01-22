//
//  Coordinates.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/22/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import Foundation

struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
