//  Created by Juan David Cruz Serrano on 6/18/19. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

import Foundation
import UIKit

class FastRecognizedContentViewController: UIViewController {

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
        setUpAccessibility()
    }

    func updateWithText(_ text: String, confidence: Double?) {
        self.accessibilityLabel = NSLocalizedString("Last_Recognition", comment: "") + text
        if confidence != nil {
            let currentLabel = (self.accessibilityLabel ?? "") + ". "
            self.accessibilityLabel = currentLabel + NSLocalizedString("Confidence", comment: "") + String(Int(confidence!)) + "%"
        }
        DispatchQueue.main.async {
            self.recognizedObjectsLabel.text = text
            self.view.layoutIfNeeded()
        }
    }
}

extension FastRecognizedContentViewController {
    func setUpUI() {
        // General View
        self.view.backgroundColor = .clear
        // Components
        setUpRecognizedLabel()
    }

    func setUpRecognizedLabel() {
        recognizedObjectsLabel = UILabel()
        recognizedObjectsLabel.textColor = .label
        recognizedObjectsLabel.numberOfLines = .zero
        recognizedObjectsLabel.textAlignment = .center
        recognizedObjectsLabel.lineBreakMode = .byWordWrapping
        recognizedObjectsLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        recognizedObjectsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(recognizedObjectsLabel)
        NSLayoutConstraint.activate([
            recognizedObjectsLabel.topAnchor.constraint(equalTo: view.topAnchor),
            recognizedObjectsLabel.leftAnchor.constraint(equalTo: view.leftAnchor,
                                                         constant: FastRecognizedContentViewController.recognizedObjectsLabelHorizontalSpacing),
            recognizedObjectsLabel.rightAnchor.constraint(equalTo: view.rightAnchor,
                                                          constant: -FastRecognizedContentViewController.recognizedObjectsLabelHorizontalSpacing),
            recognizedObjectsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                           constant: -CameraShutterButtonView.calculateSizeOfOverSteppingHeight())
            ])
    }

    func setUpBackground() {
        guard let view = self.view else {
            return
        }
        let pickerVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        pickerVisualEffectView.frame = self.view.frame
        pickerVisualEffectView.tag = FastRecognizedContentViewController.bgEffectViewTag
        for view in self.view.subviews where view.tag == FastRecognizedContentViewController.bgEffectViewTag {
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
        pickerVisualEffectView.layer.cornerRadius = FastRecognizedContentViewController.bgEffectViewCornerRadius
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
        return label.frame.height
            + recognizedObjectsLabelVerticalSpacing * 2
            + safeAreaHeight
            + CameraShutterButtonView.calculateSizeOfOverSteppingHeight()
    }
}

extension FastRecognizedContentViewController {
    func setUpAccessibility() {
        self.shouldGroupAccessibilityChildren = true
        self.accessibilityLabel = NSLocalizedString("No_Fast_Recognition", comment: "")
        self.isAccessibilityElement = true
        #if DEVELOPMENT
        self.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: NSLocalizedString("mute_fast_recognition", comment: ""),
                                        target: self,
                                        selector: #selector(muteRecognition))
        ]
        #endif
    }
}

extension FastRecognizedContentViewController {
    @objc func muteRecognition() {
        // TODO: Mute fast recognition
    }
}

// MARK: - Update Recognized Content View
extension ARKitCameraViewController {
    func updateRecognizedContentView(text: String, confidence: Double?) {
        fastRecognizedContentViewController?.updateWithText(text, confidence: confidence)
        DispatchQueue.main.async {
            let height = FastRecognizedContentViewController.calculateHeightForText(text: text,
                                                                                    width: self.fastRecognizedContentView.frame.width,
                                                                                    safeAreaHeight: self.view.safeAreaInsets.bottom)
            self.fastRecognizedContentViewHeightContraint.constant = height
            UIView.animate(withDuration: FastRecognizedContentViewController.timeIntervalAnimateHeightChange,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
