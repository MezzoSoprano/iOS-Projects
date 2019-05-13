//
//  SocketViewCell.swift
//  ChargeMe
//
//  Created by Святослав Катола on 2/21/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

class SocketViewCell: UICollectionViewCell {
    
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeName: UILabel!
}

// MARK: - Configuation

extension SocketViewCell {
    
    func configureWith(typeName: String) {
        self.typeName.text = typeName
    
        if typeName.contains("Type 2") {
            self.typeImage.image = UIImage(named: "type2")
        } else if typeName.contains("Type 1") {
            self.typeImage.image = UIImage(named: "type1")
        } else if typeName.contains("Tesla") {
            self.typeImage.image = UIImage(named: "teslaCharg")
        } else if typeName.contains("CCS") {
            self.typeImage.image = UIImage(named: "ccs")
        } else if typeName.contains("CHAdeMO") {
            self.typeImage.image = UIImage(named: "chademo")
        } else {
            self.typeImage.image = UIImage(named: "noPicture")
        }
    }
}
