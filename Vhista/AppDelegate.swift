//
//  AppDelegate.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/1/17.
//  Copyright © 2017 juandavidcruz. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking
import Firebase
import AWSCore
import SwiftyStoreKit

let manager = AFHTTPSessionManager(baseURL: URL(string: ""))

var global_language: String = NSLocale.preferredLanguages[0]

var launchedFromShortCut: Bool = false
let NotificationShortcut = Notification.Name("HandleShortcut")

var globalRate = AVSpeechUtteranceDefaultSpeechRate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Verify Subscriptions (Currently not receiving new subscriptions)
        //SubscriptionManager.shared.completeTransactions()
        
        //Listen For Network Changes
        VhistaReachabilityManager.shared.startMonitoring()
        
        //SetUp Global Language
        if !global_language.contains("en-") && !global_language.contains("es-") {
            print("Language not supported, use English instead")
            global_language = "en-US"
        }
        
        //SetUp Firebase
        FirebaseApp.configure()
        
        //SetUp AWS
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.USEast1,
            identityPoolId: AWSPoolID)
        let configuration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print("Error: Could not set audio category: \(error), \(error.userInfo)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error: Could not setActive to true: \(error), \(error.userInfo)")
        }
        
        // Avoid Screen Dim
        application.isIdleTimerDisabled = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

