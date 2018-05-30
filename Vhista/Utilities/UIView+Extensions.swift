//
//  UIView+Extensions.swift
//  Vhista
//
//  Created by David Cruz on 3/5/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
