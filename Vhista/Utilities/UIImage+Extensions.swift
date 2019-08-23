//
//  UIImage+Extensions.swift
//  Vhista
//
//  Created by David Cruz on 5/14/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
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

    func adjustImageRotation() -> UIImage {
        var rotatedImage: UIImage = self
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation

        switch orientation {
        case .portrait:
            rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .right)
        case .landscapeRight:
            rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .down)
        case .landscapeLeft:
            rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .up)
        case .portraitUpsideDown:
            rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .left)
        default:
            rotatedImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .right)
        }
        return rotatedImage
    }
}
