//
//  ConfigurationManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/27/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation

class ConfigurationManager: NSObject {

    // MARK: - Initialization Method
    override init() {
        super.init()
    }

    static let shared: ConfigurationManager = {
        let instance = ConfigurationManager()
        return instance
    }()

    func serverAllowsRecognition(_ completition: @escaping (_ allowed: Bool) -> Void) {
        // TODO: Removed Firebase, add custom Vhista Logic.
        completition(true)
    }
}
