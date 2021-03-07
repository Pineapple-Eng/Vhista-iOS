//
//  VHRoundedButton.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 9/18/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit

struct VHRoundedButtonType {
    static let darkBackground = "darkBackground"
}

class VHRoundedButton: UIButton {

    static let bgViewCornerRadius: CGFloat = 10.0
    static let defaultHeight: CGFloat = 44.0

    var customType: String

    override init(frame: CGRect) {
        self.customType = VHRoundedButtonType.darkBackground
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        self.customType = VHRoundedButtonType.darkBackground
        super.init(coder: coder)
    }

    convenience init(frame: CGRect,
                     title: String = "Button",
                     type: String = VHRoundedButtonType.darkBackground) {
        self.init()
        self.customType = type
        setTitle(title, for: .normal)
        setUpBackground()
    }
}

extension VHRoundedButton {
    func setUpBackground() {
        switch self.customType {
        case VHRoundedButtonType.darkBackground:
            self.backgroundColor = .black
            self.setTitleColor(.white, for: .normal)
        default:
            self.backgroundColor = .black
            self.setTitleColor(.white, for: .normal)
        }
        self.clipsToBounds = true
        self.layer.cornerRadius = VHRoundedButton.bgViewCornerRadius
        self.layer.masksToBounds = true
    }
}
