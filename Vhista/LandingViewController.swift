//
//  LandingViewController.swift
//  Vhista
//
//  Created by David Cruz on 3/6/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import UIKit
import ARKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore {
            continueToApp()
        } else {
            let alertPrivacy = UIAlertController(title: NSLocalizedString("TITLE_ALERT_PRIVACY", comment: ""),
                                                 message: NSLocalizedString("MESSAGE_ALERT_PRIVACY", comment: ""),
                                                 preferredStyle: .alert)

            let actionClose = UIAlertAction(title: NSLocalizedString("CONTINUE", comment: ""),
                                            style: .default) { (_) in
                                                self.continueToApp()
            }
            alertPrivacy.addAction(actionClose)

            self.present(alertPrivacy, animated: true)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }

    func continueToApp() {
        let eventName = arEnabled ? AnalyticsConstants.LandedAREnabled:AnalyticsConstants.LandedARDisabled
        recordAnalytics(analyticsEventName: eventName, parameters: nil)
        self.performSegue(withIdentifier: "GoToARHome", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
