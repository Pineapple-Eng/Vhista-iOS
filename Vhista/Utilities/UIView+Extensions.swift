//  Created by David Cruz on 3/5/18. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

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
