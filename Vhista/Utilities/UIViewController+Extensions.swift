//  Created by David Cruz on 3/5/18. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlertView(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let actionClose = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(actionClose)

        self.present(alertController, animated: true, completion: nil)
    }
}

func getTopMostViewController() -> UIViewController? {
    if var topController = UIApplication.shared.windows.first?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    return nil
}
