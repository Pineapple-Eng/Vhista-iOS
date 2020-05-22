//
//  VHImage.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/22/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

struct VHImageSource {
    static let camera = ".camera"
    static let photoLibrary = ".photoLibrary"
}

class VHImage: NSObject {
    private var image: UIImage?
    private var imageSource: String!

    init(image: UIImage, withSource source: String) {
        super.init()
        self.image = image
        self.imageSource = source
    }

    func getUIImage() -> UIImage? {
        return self.image
    }
}
