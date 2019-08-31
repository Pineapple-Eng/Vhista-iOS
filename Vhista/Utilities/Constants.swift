//
//  Constants.swift
//  Vhista
//
//  Created by David Cruz on 5/19/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import CoreGraphics

let inceptionV3RecognitionThreshold: Float = 0.30

let frameRateInterval = 1.0

let flashLumens = CGFloat(300.0)

func getFormattedAppVersion() -> String {
    return NSLocalizedString("version", comment: "") + ": "
        + "4.0" + " - "
        + NSLocalizedString("build", comment: "") + ": "
        + "2"
}
