//
//  Setting.swift
//  ChargeMe
//
//  Created by Святослав Катола on 5/25/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import MapKit

class Settings {
    
    static var mapType: MKMapType = .standard
    static var km: Bool = true
    
    init(type: MKMapType, km: Bool) {
        Settings.mapType = type
        Settings.km = km
    }
}
