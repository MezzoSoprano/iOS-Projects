//
//  SocketType.swift
//  ChargeMe
//
//  Created by Svyatoslav Katola on 5/14/19.
//  Copyright © 2019 mezzoSoprano. All rights reserved.
//

import Foundation

enum Socket: String {
    
    case euroPlug = "Single phase"
    case CHAdeMO = "CHAdeMO"
    case CCS_SAE = "SAE Combo DC CCS"
    case teslaSupercharger = "Tesla Supercharger"
    case teslaCharger = "Tesla Wall Connector "
    case J_1772 = "J-1772"
    case threePhase = "Three Phase"
    case type2 = "Type 2"
    case type3 = "Type 3"
    case unknown = "Unknown"
    
    init(socketType: String) {
        if socketType.contains("chade") || socketType.contains("CHAde") {
            self = .CHAdeMO
        } else if socketType.contains("CCS") || socketType.contains("ccs") {
            self = .CCS_SAE
        } else if socketType.contains("type 2") || socketType.contains("Type 2") {
            self = .type2
        } else if socketType.contains("tesla") || socketType.contains("Tesla") {
            self = .teslaCharger
        } else if socketType.contains("type 3") || socketType.contains("Type 3") {
            self = .type3
        } else if socketType.contains("single") || socketType.contains("Single") {
            self = .euroPlug
        } else if socketType.contains("three") || socketType.contains("Three") {
            self = .threePhase
        } else if socketType.contains("supercharger") || socketType.contains("Supercharger") {
            self = .teslaSupercharger
        } else if socketType.contains("1772") {
            self = .J_1772
        } else {
            self = .unknown
        }
    }
}
