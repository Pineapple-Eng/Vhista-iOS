//  Created by Juan David Cruz Serrano on 8/17/17. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

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
            @unknown default:
                print("🌐 Default Unknown")
            }
            self.networkStatus = status
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
    }

    func validInternetConnection() -> Bool {
        switch self.networkStatus {
        case .notReachable, .unknown:
            return false
        case .reachableViaWWAN, .reachableViaWiFi:
            print("🌐 Network OK")
            return true
        @unknown default:
            print("🌐 Network Unknown")
            return false
        }
    }
}
