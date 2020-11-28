//
//  DistanceManager.swift
//  Vhista
//
//  Created by David Cruz on 7/15/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func getLocalizedStringForDistance(_ distance: CGFloat) -> String {
        if distance < 1.0 {
            return String(format: "%.0f", distance*100) + " " + NSLocalizedString("Centimeters", comment: "")
        } else {
            let stringMeters = String(format: "%.1f", distance)
            if stringMeters.hasSuffix(".0") {
                return  stringMeters.split(separator: ".")[0] + " " + NSLocalizedString("Meters", comment: "")
            }
            let replacePointTranslation = stringMeters.replacingOccurrences(of: ".",
                                                                            with: " " + NSLocalizedString("Point", comment: "") + " ")
            return  replacePointTranslation + " " + NSLocalizedString("Meters", comment: "")
        }
    }
}
