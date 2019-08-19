//
//  CameraShutterButtonView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/18/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class CameraShutterButtonView: UIView {

    static let buttonSize: CGFloat = 66.0
    static let paddingFromBottom: CGFloat = 8.0

    weak var buttonDelegate: VHCameraButtonDelegate?

    var shutterButton: VHCameraButton

    override init(frame: CGRect) {
        self.shutterButton = VHCameraButton()
        super.init(frame: frame)
        setUpBackground()
        setUpButton()
    }

    func setUpBackground() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.layer.cornerRadius = CameraShutterButtonView.buttonSize / 2

        let bgVisualEffectView = UIVisualEffectView(effect: secondaryBlurEffect())
        bgVisualEffectView.frame = self.frame
        self.insertSubview(bgVisualEffectView, at: .zero)
        bgVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bgVisualEffectView.widthAnchor.constraint(equalTo: self.widthAnchor),
            bgVisualEffectView.heightAnchor.constraint(equalTo: self.heightAnchor),
            bgVisualEffectView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bgVisualEffectView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        bgVisualEffectView.clipsToBounds = true
        bgVisualEffectView.layer.cornerRadius = CameraShutterButtonView.buttonSize / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraShutterButtonView {
    func setUpButton() {
        shutterButton = VHCameraButton(type: .custom)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(shutterButton, at: self.subviews.endIndex)
        NSLayoutConstraint.activate([
            shutterButton.widthAnchor.constraint(equalToConstant: CameraShutterButtonView.buttonSize),
            shutterButton.heightAnchor.constraint(equalToConstant: CameraShutterButtonView.buttonSize),
            shutterButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            shutterButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        shutterButton.buttonDelegate = self
    }
}

extension CameraShutterButtonView: VHCameraButtonDelegate {
    func didChangeCameraButtonSelection(_ button: VHCameraButton, _ selected: Bool) {
        buttonDelegate?.didChangeCameraButtonSelection(button, selected)
    }
}

extension CameraShutterButtonView {
    static func calculateSizeOfOverSteppingHeight() -> CGFloat {
        return self.buttonSize - VHBottomNavigationToolbar.estimatedToolbarHeight + self.paddingFromBottom
    }
}
