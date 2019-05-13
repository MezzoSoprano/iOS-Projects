//
//  TableCellAppereance.swift
//  ChargeMe
//
//  Created by Святослав Катола on 2/16/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

class StationTableCell: UITableViewCell, UITextFieldDelegate {
    
    let cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var pictureImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = false
        return iv
    }()
    
    var distanceLabel: UILabel = {
        let la = UILabel()
        la.translatesAutoresizingMaskIntoConstraints = false
        la.font = UIFont.systemFont(ofSize: 13)
        return la
    }()
    
    var nameLabel: UILabel = {
        let la = UILabel()
        la.translatesAutoresizingMaskIntoConstraints = false
        return la
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = LightTheme.background
        setup()
    }
    
    func setup() {
        addSubview(cellView)
        cellView.addSubview(self.nameLabel)
        cellView.addSubview(self.distanceLabel)
        cellView.addSubview(self.pictureImageView)
        
        //cellview constraits
        cellView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        cellView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        cellView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        cellView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        
        //image constraits
        pictureImageView.leftAnchor.constraint(equalTo: cellView.leftAnchor, constant: 8).isActive = true
        pictureImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        pictureImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        pictureImageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor).isActive = true
        
        //name label constraits
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -10).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: pictureImageView.rightAnchor, constant: 10).isActive = true
        
        
        //distance label constraits
        distanceLabel.leftAnchor.constraint(equalTo: pictureImageView.rightAnchor, constant: 10).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 35).isActive = true
        distanceLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -10).isActive = true
        distanceLabel.rightAnchor.constraint(equalTo: cellView.rightAnchor, constant: -10).isActive = true
        //        distanceLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configuration

extension StationTableCell {
    
    func configure(with station: ChargeStation) {
        self.nameLabel.text = station.AddressInfo?.Title ?? "Address Title not found"
        
        let distance = String(format: "%.2f", station.AddressInfo?.Distance ?? 0)
        var distanceText = "Drive: \(distance) km"
        
        if station.Connections.count > 0 {
            distanceText.append(", ")
            for item in station.Connections {
                distanceText.append(item?.ConnectionType?.Title ?? "")
                if item?.ConnectionType?.Title == station.Connections.last!?.ConnectionType?.Title {
                    break
                }
            }
        }
        
        self.distanceLabel.text = distanceText
        
        if self.distanceLabel.text!.contains("Tesla") {
            self.pictureImageView.image = UIImage(named: "superChargerPin")
        } else if self.distanceLabel.text!.contains("CHAdeMO") {
            self.pictureImageView.image = UIImage(named: "chademoChargerPin")
        } else {
            self.pictureImageView.image = UIImage(named: "chargerPin")
        }
    }
}

