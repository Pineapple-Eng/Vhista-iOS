//
//  Analytics.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 3/2/17.
//  Copyright © 2017 Juan David Cruz. All rights reserved.
//

import Foundation
import Firebase

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
    static let RequestedMoreFreeImages = "requested_more_free_images"
    static let GrantedMoreFreeImages = "granted_more_free_images"
    static let LandedVoiceOverEnabledFirstTime = "landed_voice_over_enabled_first_time"
    static let LandedVoiceOverEnabled = "landed_voice_over_enabled"
}

func recordAnalytics(analyticsEventName: String, parameters: [String: String]? = [:]) {
    DispatchQueue.main.async {
        print("Send Analytics: " + analyticsEventName)
        let completeParameters = [
            "language": globalLanguage,
            "voiceover_on": UIAccessibility.isVoiceOverRunning.description,
            "extras": parameters as Any
            ] as [String: Any]
        Analytics.logEvent(analyticsEventName, parameters: completeParameters)
    }
}
