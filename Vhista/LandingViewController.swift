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
