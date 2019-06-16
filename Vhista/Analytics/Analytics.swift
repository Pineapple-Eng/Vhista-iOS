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
        static let TakenPicture = "taken_picture"
        static let CancelButtonSubscription = "hit_cancel_button_subscription"
        static let BuyButtonSubscription = "hit_buy_button_subscription"
        static let RestoreButtonSubscription = "hit_restore_button_subscription"
        static let LandedAREnabled = "landed_ar_enabled_device"
        static let LandedARDisabled = "landed_ar_disabled_device"
        static let PictureNotSubscribed = "error_picture_unsubscribed"
        static let PictureSubscribed = "took_picture_subscribed"
        static let PictureFree = "took_free_picture"
    }

    func recordAnalytics(analyticsEventName: String, parameters: [String: NSObject]) {
        DispatchQueue.main.async {
            print("Send Analytics: " + analyticsEventName)
            Analytics.logEvent(analyticsEventName, parameters: parameters )
        }
    }

}

extension UIViewController {
    func recordAnalyticsViewController(analyticsEventName: String, parameters: [String: NSObject]) {
        DispatchQueue.main.async {
            print("Send Analytics: " + analyticsEventName)
            Analytics.logEvent(analyticsEventName, parameters: parameters )
        }
    }
}
