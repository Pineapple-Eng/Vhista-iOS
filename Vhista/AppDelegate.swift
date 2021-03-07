//
//  AppDelegate.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/1/17.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking

let manager = AFHTTPSessionManager(baseURL: URL(string: ""))

var globalLanguage: String = NSLocale.preferredLanguages[0]

var launchedFromShortCut: Bool = false
let notificationShortcut = Notification.Name("HandleShortcut")

var globalRate = AVSpeechUtteranceDefaultSpeechRate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Listen For Network Changes
        VhistaReachabilityManager.shared.startMonitoring()

        // SetUp Global Language
        if !globalLanguage.contains("en-") && !globalLanguage.contains("es-") {
            print("Language not supported, use English instead")
            globalLanguage = "en-US"
        }

        // Take control of audio only if using VoiceOver
        if UIAccessibility.isVoiceOverRunning {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            } catch let error as NSError {
                print("Error: Could not set audio category: \(error), \(error.userInfo)")
            }

            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print("Error: Could not setActive to true: \(error), \(error.userInfo)")
            }
        }

        // Avoid Screen Dim
        application.isIdleTimerDisabled = true

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
