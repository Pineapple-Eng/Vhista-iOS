//
//  UIImage+Extensions.swift
//  Vhista
//
//  Created by David Cruz on 5/14/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit
import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
