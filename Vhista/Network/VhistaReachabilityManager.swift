//
//  VhistaReachabilityManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/17/17.
//  Copyright © 2017 juandavidcruz. All rights reserved.
//

import UIKit
import AFNetworking

class VhistaReachabilityManager: NSObject {
    
    var networkStatus = AFNetworkReachabilityStatus.unknown
    
    // MARK: - Initialization Method
    override init() {
        super.init()
    }
    
    static let shared: VhistaReachabilityManager = {
        let instance = VhistaReachabilityManager()
        return instance
    }()
    
    func startMonitoring() {
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status: AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .unknown:
                print("🌐 unknown")
            case .notReachable:
                print("🌐 Not Reachable")
            case .reachableViaWWAN:
                print("🌐 Reachable WWAN")
            case .reachableViaWiFi:
                print("🌐 Reachable WiFi")
            }
            
            self.networkStatus = status
            
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
    }

}
