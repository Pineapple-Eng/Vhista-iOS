//
//  RecognizedContentViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/27/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

class RecognizedContentViewController: UIViewController {

    var recognizedObjectsTextView = UITextView()
    var actionsToolbar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    func updateWithText(_ text: String) {
        recognizedObjectsTextView.accessibilityLabel = NSLocalizedString("LAST_RECOGNITION", comment: "") + text
        DispatchQueue.main.async {
            self.recognizedObjectsTextView.text = text
            self.view.layoutIfNeeded()
        }
    }
}

extension RecognizedContentViewController {
    func setUpUI() {
    }
}
