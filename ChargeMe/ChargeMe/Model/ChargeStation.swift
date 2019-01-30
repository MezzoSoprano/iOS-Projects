//
//  ChargeStation.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/21/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import Foundation
import Contacts
import MapKit

struct ChargeStation: Codable {
    let ID: Int?
    let GeneralComments: String?
    var DateLastVerified: String?

     struct AddressInfo: Codable {
        let Title: String?
        let AddressLine1: String?
        let AddressLine2: String?
        let Town: String?
        let Latitude: Double?
        let Longitude: Double?
        let ContactTelephone1: String?
        let ContactTelephone2: String?
        let ContactEmail: String?
        let Distance: Double?
    }
    
    struct OperatorInfo: Codable {
        let WebsiteURL: String?
        let Title: String?
    }
    
    let AddressInfo: AddressInfo?
    let OperatorInfo: OperatorInfo?
    
    func createAnnotaion() -> ChargeStationAnnotation {
        return ChargeStationAnnotation(title: self.OperatorInfo?.Title ?? "Empty info", locationName: self.AddressInfo?.Title ?? "Empty info", coordinate: CLLocationCoordinate2D(latitude: self.AddressInfo?.Latitude ?? 0, longitude: self.AddressInfo?.Longitude ?? 0))
    }
}

class ChargeStationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    //let discipline: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
       // self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    var subtitle: String? {
        return locationName
    }
}
