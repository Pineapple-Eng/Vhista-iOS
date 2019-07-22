//
//  ARKit+Extensions.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/23/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//
// swiftlint:disable implicit_getter

import ARKit

var arEnabled: Bool {
    get {
        if ARConfiguration.isSupported, #available(iOS 11.3, *) {
            return true
        } else {
            return false
        }
    }
}
