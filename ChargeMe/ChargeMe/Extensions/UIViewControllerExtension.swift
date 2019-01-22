//
//  UIViewControllerExtension.swift
//  ChargeMe
//
//  Created by Святослав Катола on 1/22/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

extension UIViewController {
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
