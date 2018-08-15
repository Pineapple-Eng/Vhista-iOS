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
        if launchedBefore  {
            continueToApp()
        } else {
            let alertPrivacy = UIAlertController(title: NSLocalizedString("TITLE_ALERT_PRIVACY", comment: ""), message: NSLocalizedString("MESSAGE_ALERT_PRIVACY", comment: ""), preferredStyle: .alert)
            
            let actionClose = UIAlertAction(title: NSLocalizedString("CONTINUE", comment: ""), style: .default) { (action) in
                self.continueToApp()
            }
            alertPrivacy.addAction(actionClose)
            
            self.present(alertPrivacy, animated: true)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
    func continueToApp() {
        if ARConfiguration.isSupported, #available(iOS 11.3, *) {
            recordAnalytics(analyticsEventName: AnalyticsConstants().LandedAREnabled, parameters: [
                "language": global_language as NSObject
                ])
            self.performSegue(withIdentifier: "GoToARHome", sender: nil)
        } else {
            recordAnalytics(analyticsEventName: AnalyticsConstants().LandedARDisabled, parameters: [
                "language": global_language as NSObject
                ])
            self.performSegue(withIdentifier: "GoToNonARHome", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
