//
//  DistanceManager.swift
//  Vhista
//
//  Created by David Cruz on 7/15/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func getLocalizedStringForDistance(_ distance: CGFloat) -> String {
        if distance < 1.0 {
            return String(format: "%.0f", distance*100) + " " + NSLocalizedString("CENTIMETERS", comment: "")
        } else {
            let stringMeters = String(format: "%.1f", distance)
            if stringMeters.hasSuffix(".0") {
                return  stringMeters.split(separator: ".")[0] + " " + NSLocalizedString("METERS", comment: "")
            }

            return stringMeters.replacingOccurrences(of: ".", with: " " + NSLocalizedString("POINT", comment: "") + " ") + " " + NSLocalizedString("METERS", comment: "")
        }
    }

}
