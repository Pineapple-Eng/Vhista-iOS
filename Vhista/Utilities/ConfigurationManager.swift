//
//  ConfigurationManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/27/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation
import Firebase
import DeviceCheck

class ConfigurationManager: NSObject {

    let remoteConfig = RemoteConfig.remoteConfig()

    // MARK: - Initialization Method
    override init() {
        super.init()
    }

    static let shared: ConfigurationManager = {
        let instance = ConfigurationManager()
        return instance
    }()

    func serverAllowsRecognition(_ completition: @escaping (_ allowed: Bool) -> Void) {

        // Enable for development purposes only.
//        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.setDefaults(fromPlist: "RemoteConfig")

        remoteConfig.fetch { (status, error) in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
                print(self.remoteConfig["deep_analysis_enabled"].boolValue)
                completition(self.remoteConfig["deep_analysis_enabled"].boolValue)
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                completition(true)
            }
        }

    }

}
