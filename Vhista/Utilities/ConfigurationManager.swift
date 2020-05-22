//
//  ConfigurationManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/27/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
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
        remoteConfig.setDefaults(fromPlist: "RemoteConfig")
        remoteConfig.fetchAndActivate { (status, error) in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                print("Config fetched!")
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
