//
//  RecognizedContentViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/18/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import UIKit

class RecognizedContentViewController: UIViewController {

    var recognizedObjectsLabel = UILabel()

    static let bgEffectViewTag = 101
    static let bgEffectViewCornerRadius: CGFloat = 20.0

    static let recognizedObjectsLabelVerticalSpacing: CGFloat = 16.0
    static let recognizedObjectsLabelHorizontalSpacing: CGFloat = 8.0

    static let timeIntervalAnimateHeightChange: TimeInterval = 0.25

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpBackground()
    }

    func updateWithText(_ text: String) {
        recognizedObjectsLabel.accessibilityLabel = NSLocalizedString("LAST_RECOGNITION", comment: "") + text
        DispatchQueue.main.async {
            self.recognizedObjectsLabel.text = text
            self.view.layoutIfNeeded()
        }
    }
}

extension RecognizedContentViewController {
    func setUpUI() {
        // General View
        self.view.backgroundColor = .clear
        // Components
        setUpRecognizedLabel()
    }

    func setUpRecognizedLabel() {
        recognizedObjectsLabel = UILabel()
        recognizedObjectsLabel.textColor = getLabelDarkColorIfSupported(color: .white)
        recognizedObjectsLabel.numberOfLines = .zero
        recognizedObjectsLabel.textAlignment = .center
        recognizedObjectsLabel.lineBreakMode = .byWordWrapping
        recognizedObjectsLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        recognizedObjectsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(recognizedObjectsLabel)
        NSLayoutConstraint.activate([
            recognizedObjectsLabel.topAnchor.constraint(equalTo: view.topAnchor),
            recognizedObjectsLabel.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                         constant: RecognizedContentViewController.recognizedObjectsLabelHorizontalSpacing),
            recognizedObjectsLabel.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                          constant: -RecognizedContentViewController.recognizedObjectsLabelHorizontalSpacing),
            recognizedObjectsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }

    func setUpBackground() {
        guard let view = self.view else {
            return
        }
        let pickerVisualEffectView = UIVisualEffectView(effect: globalBlurEffect())
        pickerVisualEffectView.frame = self.view.frame
        pickerVisualEffectView.tag = RecognizedContentViewController.bgEffectViewTag
        for view in self.view.subviews where view.tag == RecognizedContentViewController.bgEffectViewTag {
            view.removeFromSuperview()
        }
        self.view.insertSubview(pickerVisualEffectView, at: .zero)
        pickerVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerVisualEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
            pickerVisualEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
            pickerVisualEffectView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerVisualEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        pickerVisualEffectView.clipsToBounds = true
        pickerVisualEffectView.layer.cornerRadius = RecognizedContentViewController.bgEffectViewCornerRadius
        pickerVisualEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    static func calculateHeightForText(text: String, width: CGFloat, safeAreaHeight: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: .zero,
                                                   y: .zero,
                                                   width: width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = text
        label.sizeToFit()
        return label.frame.height + recognizedObjectsLabelVerticalSpacing * 2 + safeAreaHeight
    }
}
