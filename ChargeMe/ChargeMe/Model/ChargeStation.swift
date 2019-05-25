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
    
    var socketTypes: [Socket] {
        var array = [Socket]()
        for item in self.Connections {
            array.append(Socket(socketType: item?.ConnectionType?.Title ?? ""))
        }
        
        return array
    }
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
        let Title: String?
        let WebsiteURL: String?
        let PhonePrimaryContact: String?
        let ContactEmail: String?
    }
    
    struct Connections: Codable {
        let ID: Int?
        let ConnectionType: ConnectionType?
        
        struct ConnectionType: Codable {
            let Title: String?
        }
    }
    
    var needMembership: Bool {
        
        if let usage = self.UsageType {
            if let p1 = usage.IsAccessKeyRequired, let p2 = usage.IsMembershipRequired {
                if p1 || p2 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    var needPayForLocation: Bool {
        
        if let usage = self.UsageType {
            if let p1 = usage.IsPayAtLocation {
                if p1 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }

    struct UsageType: Codable {
        let IsPayAtLocation: Bool?
        let IsMembershipRequired: Bool?
        let IsAccessKeyRequired: Bool?
    }
    
    struct MediaItems: Codable {
        let ItemThumbnailURL: String?
        let ItemURL: String?
    }
    
    let MediaItems: [MediaItems?]?
    let AddressInfo: AddressInfo?
    let OperatorInfo: OperatorInfo?
    let Connections: [Connections?]
    let UsageType: UsageType?
    
    func createAnnotaion() -> ChargeStationAnnotation {
        
        var str = ""
        
        if self.Connections.count > 0 {
            for item in  self.Connections {
                if item?.ConnectionType?.Title ==  self.Connections.last!?.ConnectionType?.Title {
                    str += (item?.ConnectionType?.Title!)!
                    break
                }
                str += (item?.ConnectionType?.Title!)! + ", "
            }
        }
        
        return ChargeStationAnnotation(title: str, locationName: self.AddressInfo?.Title ?? "Empty info", coordinate: CLLocationCoordinate2D(latitude: self.AddressInfo?.Latitude ?? 0, longitude: self.AddressInfo?.Longitude ?? 0))
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

// methods

extension ChargeStation {
    
    func suitsFor(vehicle: ElectricVehicle) -> Bool {
        if vehicle.modelName == ElectricVehicle().modelName {
            return true
        } else {
            
            for connectType in self.Connections {
    
                for socket in vehicle.compatibleSockets {
                    switch socket {
                        
                    case .euroPlug:
                        if (connectType?.ConnectionType?.Title?.contains("euro"))! { return true }
                    case .CHAdeMO:
                        if (connectType?.ConnectionType?.Title?.contains("CHAd"))! { return true }
                    case .CCS_SAE:
                        if (connectType?.ConnectionType?.Title?.contains("CCS"))! { return true }
                    case .teslaSupercharger:
                        if (connectType?.ConnectionType?.Title?.contains("Supercharger"))! { return true }
                    case .teslaCharger:
                        if (connectType?.ConnectionType?.Title?.contains("Tesla"))! { return true }
                    case .J_1772:
                        if (connectType?.ConnectionType?.Title?.contains("J1772"))! { return true }
                    case .threePhase:
                        if (connectType?.ConnectionType?.Title?.contains("Three"))! { return true }
                    case .type2:
                        if (connectType?.ConnectionType?.Title?.contains("Type 2"))! { return true }
                    case .type3:
                        if (connectType?.ConnectionType?.Title?.contains("Type 3"))! { return true }
                    case .unknown:
                        print("UKNOWN SOCKET TYPE !")
                    }
                }
            }
            return false
        }
    }
}
