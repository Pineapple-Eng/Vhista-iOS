//
//  UIViewController+Extensions.swift
//  Vhista
//
//  Created by David Cruz on 3/5/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlertView(title: String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionClose = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(actionClose)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
