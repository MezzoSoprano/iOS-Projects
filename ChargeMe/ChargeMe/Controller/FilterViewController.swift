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
    
    var selectedVehicle = eVehicles[0]
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var vehiclePicker: UIPickerView!
    
    @IBOutlet weak var needMembershipSwitch: UISwitch!
    @IBOutlet weak var payForLocationSwitch: UISwitch!
    
    
    @IBOutlet weak var chademoSwitch: UISwitch!
    @IBOutlet weak var EuroWalletPlugSwitch: UISwitch!
    @IBOutlet weak var j_1772Switch: UISwitch!
    @IBOutlet weak var teslaSuperchargerSwitch: UISwitch!
    @IBOutlet weak var type3Switch: UISwitch!
    @IBOutlet weak var type2Switch: UISwitch!
    @IBOutlet weak var saeComboCCSSwitch: UISwitch!

    
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
    
    override func viewWillAppear(_ animated: Bool) {
        configureWithFilter()
    }
    
    fileprivate func configureWithFilter() {
        needMembershipSwitch.isOn = Filter.needMembership
        payForLocationSwitch.isOn = Filter.payForLocation
        
        configureSocketFilterWith(vehicle: Filter.currentVehicle)
    }
}

// MARK: - Actions

extension FilterViewController {
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    fileprivate func switchOffSocketFilter() {
        self.chademoSwitch.setOn(false, animated: true)
        self.type3Switch.setOn(false, animated: true)
        self.type2Switch.setOn(false, animated: true)
        self.EuroWalletPlugSwitch.setOn(false, animated: true)
        self.j_1772Switch.setOn(false, animated: true)
        self.saeComboCCSSwitch.setOn(false, animated: true)
        self.teslaSuperchargerSwitch.setOn(false, animated: true)
    }
    
    fileprivate func configureSocketFilterWith(vehicle: ElectricVehicle) {
        switchOffSocketFilter()
        
        for socket in vehicle.compatibleSockets {
            switch socket {
                
            case .euroPlug:
                self.EuroWalletPlugSwitch.setOn(true, animated: true)
            case .CHAdeMO:
                self.chademoSwitch.setOn(true, animated: true)
            case .CCS_SAE:
                self.saeComboCCSSwitch.setOn(true, animated: true)
            case .teslaSupercharger:
                self.teslaSuperchargerSwitch.setOn(true, animated: true)
            case .teslaCharger:
                self.type2Switch.setOn(true, animated: true)
            case .J_1772:
                self.j_1772Switch.setOn(true, animated: true)
            case .threePhase:
                print("need add three phase filter")
            case .type2:
                self.type2Switch.setOn(true, animated: true)
            case .type3:
                self.type3Switch.setOn(true, animated: true)
            case .unknown:
                print("UKNOWN SOCKET TYPE !")
            }
        }
    }
    
    @IBAction func payForLocationDidChange(_ sender: UISwitch) {
        Filter.payForLocation = sender.isOn
    }
    
    @IBAction func needMembershipDidChange(_ sender: UISwitch) {
        Filter.needMembership = sender.isOn
    }
}

// MARK: - Picker View Delegate, Picker View Delegate

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return eVehicles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return eVehicles[row].modelName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedVehicle = eVehicles[row]
        Filter.currentVehicle = selectedVehicle
        configureSocketFilterWith(vehicle: selectedVehicle)
    }
}
