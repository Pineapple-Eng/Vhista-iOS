//
//  Analytics.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 3/2/17.
//  Copyright © 2017 Juan David Cruz. All rights reserved.
//

import Foundation
import Firebase


extension NSObject {
    
    struct AnalyticsConstants {
        let TakenPicture = "taken_picture"
        let CancelButtonSubscription = "hit_cancel_button_subscription"
        let BuyButtonSubscription = "hit_buy_button_subscription"
        let RestoreButtonSubscription = "hit_restore_button_subscription"
        
    }
    
    func recordAnalytics(analyticsEventName: String, parameters: [String: NSObject]) {
        DispatchQueue.main.async {
            print("Send Analytics: " + analyticsEventName)
            Analytics.logEvent(analyticsEventName, parameters:parameters )
        }
    }
    
}

extension UIViewController {
    func recordAnalyticsViewController(analyticsEventName: String, parameters: [String: NSObject]) {
        DispatchQueue.main.async {
            print("Send Analytics: " + analyticsEventName)
            Analytics.logEvent(analyticsEventName, parameters:parameters )
        }
    }
}
