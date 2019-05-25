//
//  SettingsViewController.swift
//  ChargeMe
//
//  Created by Святослав Катола on 5/25/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func mapSettingDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Settings.mapType = .standard
        case 1:
            Settings.mapType = .hybrid
        case 2:
            Settings.mapType = .satellite
        default:
            Settings.mapType = .standard
        }
    }
    @IBAction func unitSettingDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Settings.km = true
        case 1:
            Settings.km = false
        default:
            Settings.km = true
        }
    }
}
