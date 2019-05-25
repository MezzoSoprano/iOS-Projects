//
//  Vehicle.swift
//  ChargeMe
//
//  Created by Svyatoslav Katola on 5/15/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import Foundation

struct ElectricVehicle {
    
    let modelName: String
    
    let compatibleSockets: [Socket]
    
    init(model: String, sockets: [Socket]) {
        self.modelName = model
        self.compatibleSockets = sockets
    }
    
    init() {
        self.modelName = "None"
        self.compatibleSockets = [.CCS_SAE, .CHAdeMO, .euroPlug, .J_1772, .teslaCharger, .teslaSupercharger, .threePhase, .type3, .type2]
    }
}

let emptyVhicle = ElectricVehicle()
let TeslaModelX = ElectricVehicle(model: "Tesla Model X", sockets: [.teslaCharger, .teslaSupercharger, .J_1772, .euroPlug, .threePhase])
let TeslaModelS = ElectricVehicle(model: "Tesla Model S", sockets: [.teslaCharger, .teslaSupercharger, .J_1772, .euroPlug, .threePhase])
let TeslaModel3 = ElectricVehicle(model: "Tesla Model 3", sockets: [.teslaCharger, .teslaSupercharger, .J_1772, .euroPlug, .threePhase, Socket.CCS_SAE])
let NissanLeaf = ElectricVehicle(model: "Nissan Leaf", sockets: [Socket.type2, Socket.CHAdeMO, Socket.euroPlug])
let RenaultZoe = ElectricVehicle(model: "Nissan Leaf", sockets: [Socket.type2, Socket.euroPlug])

let eVehicles = [emptyVhicle, TeslaModel3, TeslaModelS, TeslaModelX, NissanLeaf, RenaultZoe]
