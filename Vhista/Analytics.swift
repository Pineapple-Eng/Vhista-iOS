//
//  Analytics.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 3/2/17.
//  Copyright © 2017 Juan David Cruz. All rights reserved.
//

import Foundation
import Firebase


extension UIViewController {
    
    struct AnalyticsConstants {
        let TakenPicture = "taken_picture"
    }
    
    func recordAnalytics(analyticsEventName: String, parameters: [String: NSObject]) {
        DispatchQueue.main.async {
            
            print("Send Analytics: " + analyticsEventName)
            Analytics.logEvent(analyticsEventName, parameters:parameters )
            
        }
    }
    
    
}
