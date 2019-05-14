//
//  ChargeInfoViewModel.swift
//  ChargeMe
//
//  Created by Svyatoslav Katola on 5/13/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

// MARK: - View Model

class ChargeInfoViewModel {
    
    private let station: ChargeStation
    
    private var progressIndicator: UIActivityIndicatorView = {
        let pi = UIActivityIndicatorView(style: .whiteLarge)
        pi.color = UIColor(r: 127, g: 181, b: 181)
        return pi
    }()
    
    public init(station: ChargeStation) {
        self.station = station
    }
    
    public var driveDistanceText: String {
        let distanceText = String(format: "%.2f", station.AddressInfo?.Distance ?? 0)
        var text = "Drive: \(distanceText) km"
        
        if station.Connections.count > 0 {
            text.append(", ")
            for item in station.Connections {
               text.append(item?.ConnectionType?.Title ?? "")
                if item?.ConnectionType?.Title == station.Connections.last!?.ConnectionType?.Title {
                    break
                }
            }
        }
        
        return text
    }
    
    public var socketsNames: [String] {
        var names = [String]()
        
        for item in station.Connections {
            names.append(item?.ConnectionType?.Title ?? "?")
        }
        
        return names
    }
    
    public var imagesURL: [String] {
        var  images = [String]()
        
        if let mediaItems = station.MediaItems {
            for item in mediaItems {
                if let imageURL = item?.ItemURL {
                    images.append(imageURL)
                }
            }
        }
        
        return images
    }
    
    public var addressNameText: String {
        return station.AddressInfo?.Title ?? ""
    }
    
    public var emailText: String {
        return station.OperatorInfo?.ContactEmail ?? "Empty info."
    }
    
    public var phoneText: String {
        return station.OperatorInfo?.PhonePrimaryContact ?? "Empty info."
    }
    
    public var websiteURLText: String {
        return station.OperatorInfo?.WebsiteURL ?? "Empty info."
    }
}

// MARK: - Concrete Configuration (ChargeInfoView Controller)

extension ChargeInfoViewModel {
    
    public func configureWith(view: StationInfoViewController) {
        
        view.addreNameLabel.text = self.addressNameText
        view.distanceSocketsLabel.text = self.driveDistanceText
        
        view.contactEmailLabel.text = self.emailText
        view.contactPhoneLabel.text = self.phoneText
        view.contactWebSiteLabel.text = self.websiteURLText
        
        progressIndicator.center = CGPoint(x: view.chargerPhotosScrollView.center.x - 15, y: view.chargerPhotosScrollView.center.y)
        progressIndicator.startAnimating()
        view.chargerPhotosScrollView.addSubview(progressIndicator)
        
        if imagesURL.count > 0 {
            for item in self.imagesURL {
                view.chargerPhotosScrollView.auk.show(url: item)
            }
        } else {
            view.chargerPhotosScrollView.auk.show(image: UIImage(named: "noPicture")!)
        }
    }
}
