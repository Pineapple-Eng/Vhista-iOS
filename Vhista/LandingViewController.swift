//  Created by David Cruz on 3/6/18. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

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
            let alertPrivacy = UIAlertController(title: NSLocalizedString("Title_Alert_Privacy", comment: ""),
                                                 message: NSLocalizedString("Message_Alert_Privacy", comment: ""),
                                                 preferredStyle: .alert)

            let actionClose = UIAlertAction(title: NSLocalizedString("Continue", comment: ""),
                                            style: .default) { (_) in
                                                self.continueToApp()
            }
            alertPrivacy.addAction(actionClose)

            self.present(alertPrivacy, animated: true)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }

    func continueToApp() {
        self.performSegue(withIdentifier: "GoToARHome", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
