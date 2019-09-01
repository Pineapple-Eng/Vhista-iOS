//
//  VHCloseButton.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/31/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class VHCloseButton: UIButton {

    static let closeButtonSize: CGFloat = 20.0
    static let systemImageName: String = "xmark"

    var circleBackgroundView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBackground()
        setUpButtonImage()
        setUpAccessibility()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpBackground()
        setUpButtonImage()
        setUpAccessibility()
    }
}

extension VHCloseButton {
    func setUpBackground() {
        circleBackgroundView = UIView(frame: .zero)
        circleBackgroundView.backgroundColor = getLabelDarkColorIfSupported(color: .lightGray)
        circleBackgroundView.layer.cornerRadius = VHCloseButton.closeButtonSize/2
        circleBackgroundView.layer.masksToBounds = true
        self.addSubview(circleBackgroundView)
        self.sendSubviewToBack(circleBackgroundView)
        circleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleBackgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleBackgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            circleBackgroundView.widthAnchor.constraint(equalToConstant: VHCloseButton.closeButtonSize),
            circleBackgroundView.heightAnchor.constraint(equalToConstant: VHCloseButton.closeButtonSize)
        ])
    }

    func setUpButtonImage() {
        self.tintColor = getLabelDarkColorIfSupported(color: .black)
        if #available(iOS 13.0, *) {
            self.setImage(UIImage(systemName: VHCloseButton.systemImageName), for: .normal)
        } else {
            self.setImage(UIImage(), for: .normal)
        }
    }
}

extension VHCloseButton {
    func setUpAccessibility() {
        self.accessibilityLabel = NSLocalizedString("dismiss", comment: "")
    }
}
