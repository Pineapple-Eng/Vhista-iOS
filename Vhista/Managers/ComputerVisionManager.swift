//
//  ComputerVisionManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation

class ComputerVisionManager: NSObject {

    // MARK: - Initialization Method
    override init() {
        super.init()
    }

    static let shared: ComputerVisionManager = {
        let instance = ComputerVisionManager()
        return instance
    }()
}
