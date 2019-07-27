//
//  DarkModeManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/8/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import UIKit

func globalBlurEffect() -> UIBlurEffect {
    if #available(iOS 13.0, *) {
        return UIBlurEffect(style: .systemChromeMaterial)
    } else {
        return UIBlurEffect(style: .dark)
    }
}

func getLabelDarkColorIfSupported(color: UIColor) -> UIColor {
    guard #available(iOS 13.0, *) else {
        return color
    }
    switch color {
    case .white, .black:
        return UIColor.label
    default:
        return color
    }
}
