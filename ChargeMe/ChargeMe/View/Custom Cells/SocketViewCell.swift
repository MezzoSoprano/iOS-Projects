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
    
    func configureWith(socket: Socket) {
        self.typeName.text = socket.rawValue
        
        switch socket {
        case .CCS_SAE:
            self.typeImage.image = UIImage(named: "ccs")
        case .euroPlug:
            self.typeImage.image = UIImage(named: "type1")
        case .CHAdeMO:
            self.typeImage.image = UIImage(named: "chademo")
        case .teslaSupercharger:
            self.typeImage.image = UIImage(named: "teslaCharg")
        case .J_1772:
            self.typeImage.image = UIImage(named: "J-1772")
        case .threePhase:
            self.typeImage.image = UIImage(named: "Three Phase (EU)")
        case .type2:
            self.typeImage.image = UIImage(named: "type2")
        case .type3:
            self.typeImage.image = UIImage(named: "noPicture")
        case .unknown:
            self.typeImage.image = UIImage(named: "noPicture")
        }
    }
}
