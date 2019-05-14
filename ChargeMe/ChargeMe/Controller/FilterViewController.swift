//
//  FilterViewController.swift
//  ChargeMe
//
//  Created by Svyatoslav Katola on 5/14/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class FilterViewController: UIViewController {
    
    weak var delegate: ModalViewControllerDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor.clear
        
        //ensure that the icon embeded in the cancel button fits in nicely
        cancelButton.imageView?.contentMode = .scaleAspectFit
        
        //add a white tint color for the Cancel button image
        let cancelImage = UIImage(named: "Cancel")
        
        let tintedCancelImage = cancelImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedCancelImage, for: .normal)
        cancelButton.tintColor = .white
    }
}

// MARK: - Actions

extension FilterViewController {
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
}
