//
//  UIColorExtension.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/23/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
