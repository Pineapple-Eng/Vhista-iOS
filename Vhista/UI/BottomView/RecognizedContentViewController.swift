//
//  RecognizedContentViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/27/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

protocol RecognizedContentViewControllerDelegate: class {
    func willDismissRecognizedContentViewController(_ controller: RecognizedContentViewController)
}

class RecognizedContentViewController: UIViewController {

    weak var delegate: RecognizedContentViewControllerDelegate?

    var recognizedObjectsTextView: UITextView!
    var actionsToolbar: UIToolbar!

    static let recognizedTextViewHorizontalSpacing: CGFloat = 8.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.willDismissRecognizedContentViewController(self)
    }

    func updateWithText(_ text: String) {
        recognizedObjectsTextView.accessibilityLabel = NSLocalizedString("LAST_RECOGNITION", comment: "") + text
        DispatchQueue.main.async {
            self.recognizedObjectsTextView.text = text
            self.view.layoutIfNeeded()
        }
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged,
                             argument: recognizedObjectsTextView)
    }
}

extension RecognizedContentViewController {
    func setUpUI() {
        setUpBackground()
        setUpToolbar()
        setUpTextView()
    }

    func setUpBackground() {
            guard let view = self.view else {
                return
            }
            let pickerVisualEffectView = UIVisualEffectView(effect: globalBlurEffect())
            pickerVisualEffectView.frame = self.view.frame
            self.view.insertSubview(pickerVisualEffectView, at: .zero)
            pickerVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pickerVisualEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
                pickerVisualEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
                pickerVisualEffectView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                pickerVisualEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }

    func setUpTextView() {
        recognizedObjectsTextView = UITextView(frame: .zero)
        recognizedObjectsTextView.textColor = getLabelDarkColorIfSupported(color: .white)
        recognizedObjectsTextView.isEditable = false
        recognizedObjectsTextView.isSelectable = false
        recognizedObjectsTextView.backgroundColor = .clear
        recognizedObjectsTextView.textAlignment = .center
        recognizedObjectsTextView.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        recognizedObjectsTextView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(recognizedObjectsTextView)
        NSLayoutConstraint.activate([
            recognizedObjectsTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            recognizedObjectsTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                                            constant: RecognizedContentViewController.recognizedTextViewHorizontalSpacing),
            recognizedObjectsTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                             constant: -RecognizedContentViewController.recognizedTextViewHorizontalSpacing),
            recognizedObjectsTextView.bottomAnchor.constraint(equalTo: actionsToolbar.topAnchor)
        ])
    }

    func setUpToolbar() {
        actionsToolbar = UIToolbar()
        actionsToolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(actionsToolbar)
        NSLayoutConstraint.activate([
            actionsToolbar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            actionsToolbar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            actionsToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
